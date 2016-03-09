/* 
 * Purpose:  Use iterative depth-first search and OpenMP to solve an 
 *           instance of the travelling salesman problem.  
 *
 * Compile:  gcc -O3 -Wall -fopenmp -o tsp tsp.c
 * Usage:    ./tsp <thread count> <matrix_file>
 *
 * Input:    From a user-specified file, the number of cities
 *           followed by the costs of travelling between the
 *           cities organized as a matrix:  the cost of
 *           travelling from city i to city j is the ij entry.
 *           Costs are nonnegative ints.  Diagonal entries are 0.
 * Output:   The best tour found by the program and the cost
 *           of the tour.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>
#include <limits.h>
#include <assert.h>
#define max(a,b) ((a>b)?a:b);
const int INFINITY = INT_MAX;
const int NO_CITY = -1;
const int FALSE = 0;
const int TRUE = 1;
const int MAX_STRING = 1000;

typedef int city_t;
typedef int cost_t;

typedef struct {
   city_t* cities; /* Cities in partial tour           */
   int count;      /* Number of cities in partial tour */
   cost_t cost;    /* Cost of partial tour             */
} tour_struct;

typedef tour_struct* tour_t;
#define City_count(tour) (tour->count)
#define Tour_cost(tour) (tour->cost)
#define Last_city(tour) (tour->cities[(tour->count)-1])
#define Tour_city(tour,i) (tour->cities[(i)])

typedef struct {
   tour_t* list;
   int list_sz;
   int list_alloc;
   int id;
}  stack_struct;
typedef stack_struct* my_stack_t;

/* Global Vars: */
int n;  /* Number of cities in the problem */
int thread_count;
cost_t* digraph;
#define Cost(city1, city2) (digraph[city1*n + city2])
city_t home_town = 0;
tour_t best_tour;
int init_tour_count;
my_stack_t obj_pool;
void Usage(char* prog_name);
void Read_digraph(FILE* digraph_file);
void Print_digraph(void);

void Par_tree_search(void); // TODO: Implement this function
void Serial_tree_search(my_stack_t,tour_t);
void Set_init_tours(int my_rank, int* my_first_tour_p,\
      int* my_last_tour_p);

void Print_tour(int my_rank, tour_t tour, char* title);
int  Best_tour(tour_t tour); 
void Update_best_tour(tour_t tour);
void Copy_tour(tour_t tour1, tour_t tour2);
void Add_city(tour_t tour, city_t);
void Remove_last_city(tour_t tour);
int  Feasible(tour_t tour, city_t city);
int  Visited(tour_t tour, city_t city);
void Init_tour(tour_t tour, cost_t cost);
tour_t Alloc_tour(my_stack_t avail);
void Free_tour(tour_t tour, my_stack_t avail);
void Push(my_stack_t stack, tour_t tour){
   if(stack->list_sz >= stack->list_alloc){
      fprintf(stderr,"Stack overflow for stack %d\n",stack->id);
      exit(1);
   }
   stack->list[stack->list_sz++] = tour;
}
tour_t Pop(my_stack_t stack){
   if(stack->list_sz == 0) {
      printf("Pop from empty stack! id: %d\n",stack->id);
      exit(1);
   }
   return stack->list[--stack->list_sz];
}
int Empty_stack(my_stack_t stack){
   return stack->list_sz==0;
}
void Push_copy(my_stack_t stack, tour_t tour){
   tour_t copy = Alloc_tour(obj_pool);
   Copy_tour(tour,copy);
   Push(stack,copy);
}
void Alloc_stack(my_stack_t stack,int id,int max_size){
   assert(max_size > 0);
   printf("%d\n",id);
   fflush(stdout);
   stack->list  = (tour_t*)malloc(max_size*sizeof(tour_struct));
   if(!stack->list){
      fprintf(stderr,"Out of memory!\n");
      exit(1); 
   }
   stack->id = id;
   stack->list_sz = 0;
   stack->list_alloc = max_size;
}

/*------------------------------------------------------------------*/
int main(int argc, char* argv[]) {
   FILE* digraph_file;
   double start, finish;

   if (argc != 3) Usage(argv[0]);
   thread_count = strtol(argv[1], NULL, 10);
   if (thread_count <= 0) {
      fprintf(stderr, "Thread count must be positive\n");
      Usage(argv[0]);
   }
   digraph_file = fopen(argv[2], "r");
   if (digraph_file == NULL) {
      fprintf(stderr, "Can't open %s\n", argv[2]);
      Usage(argv[0]);
   }
   Read_digraph(digraph_file);
   fclose(digraph_file);
#  ifdef DEBUG
   Print_digraph();
#  endif   

   best_tour = Alloc_tour(NULL);
   Init_tour(best_tour, INFINITY);
#  ifdef DEBUG
   Print_tour(-1, best_tour, "Best tour");
   printf("City count = %d\n",  City_count(best_tour));
   printf("Cost = %d\n\n", Tour_cost(best_tour));
#  endif
   
   start = omp_get_wtime();
   Par_tree_search();
   finish = omp_get_wtime();
   
   Print_tour(-1, best_tour, "Best tour");
   printf("Cost = %d\n", best_tour->cost);
   printf("Time = %e seconds\n", finish-start);

   free(best_tour->cities);
   free(best_tour);
   free(digraph);
   return 0;
}  /* main */
#define STACK_SIZE 1000
void Par_tree_search(){
   //allocate stacks to each thread
   printf("thread_count : %d\n",thread_count);
   my_stack_t* thread_stacks = (my_stack_t*)malloc((thread_count+1)*sizeof(my_stack_t));
   
   int thread_id;

   for(thread_id = 0; thread_id < thread_count; thread_id++){
      thread_stacks[thread_id] = (my_stack_t)malloc(sizeof(stack_struct));
      Alloc_stack(thread_stacks[thread_id],thread_id,STACK_SIZE);
   }
   
   tour_t init_tour = Alloc_tour(obj_pool);
   Init_tour(init_tour,0);
    
   
   int work_queue_len = max(n,2*thread_count);
   printf("work_queue_len : %d\n",work_queue_len);

   int work_queue_size = 0,start=0,end=0;  
   tour_t* work_queue = (tour_t*)malloc(work_queue_len*sizeof(tour_t));
   memset(work_queue,0,work_queue_len*sizeof(tour_t));
   work_queue[0] = init_tour;
   work_queue_size++;end++;
   while(work_queue_size > 0 && work_queue_size < thread_count){
      tour_t curr_tour = work_queue[start];
      work_queue[start] = 0;
      start = (start+1)%work_queue_len;
      work_queue_size--;
      int nbr;
      for(nbr = n-1; nbr >=1 ; nbr--){
         if(!Visited(curr_tour,nbr)){
            printf("%d %d\n",work_queue_len,work_queue_size);
            assert(work_queue_size <=work_queue_len);
            tour_t copy = Alloc_tour(obj_pool);
            Copy_tour(curr_tour,copy);
            Add_city(copy,nbr);
            work_queue[end] = copy;
            end = (end+1)%work_queue_len;
            work_queue_size++;
         }
      }
      Free_tour(curr_tour,obj_pool);
   }
   printf("%d nodes in work queue\n",work_queue_size);
   omp_set_num_threads(thread_count);
   int nthreads;
   #pragma omp parallel 
   {
      #pragma omp single
      nthreads = omp_get_num_threads();
      int tid = omp_get_thread_num();
      int i;
      for(i = tid;work_queue_size > 0 && i < work_queue_size; i += nthreads){
         int wq_idx = (start+i)%work_queue_size;
         if(work_queue[wq_idx] == 0) break;
         Serial_tree_search(thread_stacks[tid],work_queue[wq_idx]);
      }
        
   }
   printf("Done!\n");
   free(thread_stacks);
   free(work_queue);
}
void Serial_tree_search(my_stack_t stack,tour_t partial_tour){
   assert(stack);
   assert(partial_tour);
   Push(stack,partial_tour);
   while(!Empty_stack(stack)){
      tour_t curr_tour = Pop(stack);
      if(City_count(curr_tour) == n){
         Update_best_tour(curr_tour);
      }
      else{
         int nbr;
         for(nbr = n-1; nbr >= 1; nbr--){
            if(Feasible(curr_tour,nbr)){
               Add_city(curr_tour,nbr);
               Push_copy(stack,curr_tour);
               Remove_last_city(curr_tour);
            }
         }
      }
      Free_tour(curr_tour,obj_pool);
   }
}

void Init_tour(tour_t tour, cost_t cost) {
   int i;

   tour->cities[0] = 0; // hometown added as a starting point
   for (i = 1; i <= n; i++) {
      tour->cities[i] = NO_CITY;
   }
   tour->cost = cost;
   tour->count = 1;
}  /* Init_tour */



void Usage(char* prog_name) {
   fprintf(stderr, "usage: %s <thread_count> <digraph file>\n", prog_name);
   exit(0);
}  /* Usage */


void Read_digraph(FILE* digraph_file) {
   int i, j;

   fscanf(digraph_file, "%d", &n);
   if (n <= 0) {
      fprintf(stderr, "Number of vertices in digraph must be positive\n");
      exit(-1);
   }
   digraph = malloc(n*n*sizeof(cost_t));

   for (i = 0; i < n; i++)
      for (j = 0; j < n; j++) {
         fscanf(digraph_file, "%d", &digraph[i*n + j]);
         if (i == j && digraph[i*n + j] != 0) {
            fprintf(stderr, "Diagonal entries must be zero\n");
            exit(-1);
         } else if (i != j && digraph[i*n + j] <= 0) {
            fprintf(stderr, "Off-diagonal entries must be positive\n");
            fprintf(stderr, "diagraph[%d,%d] = %d\n", i, j, digraph[i*n+j]);
            exit(-1);
         }
      }
}  /* Read_digraph */



void Print_digraph(void) {
   int i, j;

   printf("Order = %d\n", n);
   printf("Matrix = \n");
   for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++)
         printf("%2d ", digraph[i*n+j]);
      printf("\n");
   }
   printf("\n");
}  /* Print_digraph */



int Best_tour(tour_t tour) {
   cost_t cost_so_far = Tour_cost(tour);
   city_t last_city = Last_city(tour);

   if (cost_so_far + Cost(last_city, home_town) < Tour_cost(best_tour))
      return TRUE;
   else
      return FALSE;
}  /* Best_tour */


void Update_best_tour(tour_t tour) {

   if (Best_tour(tour)) {
      #pragma omp critical
      Copy_tour(tour, best_tour);
      #pragma omp critical
      Add_city(best_tour, home_town);
   }
}  /* Update_best_tour */


void Copy_tour(tour_t tour1, tour_t tour2) {

   memcpy(tour2->cities, tour1->cities, (n+1)*sizeof(city_t));
   tour2->count = tour1->count;
      tour2->cost = tour1->cost;
}  /* Copy_tour */


void Add_city(tour_t tour, city_t new_city) {
   city_t old_last_city = Last_city(tour);
   tour->cities[tour->count] = new_city;
   (tour->count)++;
   tour->cost += Cost(old_last_city,new_city);
}  /* Add_city */ 


void Remove_last_city(tour_t tour) {
   city_t old_last_city = Last_city(tour);
   city_t new_last_city;
   
   tour->cities[tour->count-1] = NO_CITY;
   (tour->count)--;
   new_last_city = Last_city(tour);
   tour->cost -= Cost(new_last_city,old_last_city);
}  /* Remove_last_city */


int Feasible(tour_t tour, city_t city) {
   city_t last_city = Last_city(tour);

   int best_cost;
   best_cost = Tour_cost(best_tour);
   if (!Visited(tour, city) && 
        Tour_cost(tour) + Cost(last_city,city) < best_cost)
      return TRUE;
   else
      return FALSE;
}  /* Feasible */

int Visited(tour_t tour, city_t city) {
   int i;

   for (i = 0; i < City_count(tour); i++)
      if ( Tour_city(tour,i) == city ) return TRUE;
   return FALSE;
}  /* Visited */


void Print_tour(int my_rank, tour_t tour, char* title) {
   int i;
   char string[MAX_STRING];

   if (my_rank >= 0)
      sprintf(string, "Th %d > %s %p: ", my_rank, title, tour);
   else
      sprintf(string, "%s = ", title);
   for (i = 0; i < City_count(tour); i++)
      sprintf(string + strlen(string), "%d ", Tour_city(tour,i));
   printf("%s\n", string);
}  /* Print_tour */

tour_t Alloc_tour(my_stack_t avail) {
   tour_t tmp;

   if (avail == NULL || Empty_stack(avail)) {
      tmp = malloc(sizeof(tour_struct));
      tmp->cities = malloc((n+1)*sizeof(city_t));
      return tmp;
   } else {
      return Pop(avail);
   }
}  /* Alloc_tour */


void Free_tour(tour_t tour, my_stack_t avail) {
   if (avail == NULL) {
      free(tour->cities);
      free(tour);
   } else {
      Push(avail, tour);
   }
}  /* Free_tour */

