#include <stdint.h>
#include <stdio.h>


#define BIMODAL_TABLE_SIZE 512
#define BIMODAL_HISTORY_BITS 9
#define MAX_COUNTER 3

#define LOCAL_GLOBAL_TABLE_SIZE 128
#define LOCAL_GLOBAL_HISTORY_SIZE 128
#define LOCAL_GLOBAL_HISTORY_BITS 7
#define GSHARE_GLOBAL_TABLE_SIZE 32
#define GSHARE_GLOBAL_HISTORY_SIZE 32
#define GSHARE_GLOBAL_HISTORY_BITS 5
#define GLOBAL_MAX_COUNTER 3

#define LOCAL_TABLE_SIZE 512
#define LOCAL_HISTORY_SIZE 512
#define LOCAL_HISTORY_BITS 9
#define LOCAL_MAX_COUNTER 3

#define CHOICE_TABLE_SIZE 2048
#define CHOICE_HISTORY_SIZE 2048
#define CHOICE_HISTORY_BITS 11
#define CHOICE_MAX_COUNTER 3

int bimodal_table[BIMODAL_TABLE_SIZE];
// int global_table[GLOBAL_TABLE_SIZE];
int local_history_table[LOCAL_TABLE_SIZE];
int local_table[LOCAL_TABLE_SIZE];
int choice_table[CHOICE_TABLE_SIZE];


extern "C" void initialize_branch_predictor()
{




  for (int i = 0; i < BIMODAL_TABLE_SIZE; i++)
    bimodal_table[i] = 0;

  // for(int i = 0; i < GLOBAL_TABLE_SIZE; i++){
  // 	global_table[i] = 0;
  // }

  for(int i = 0; i < LOCAL_TABLE_SIZE; i++){
  	local_history_table[i] = 0;
  }
  for(int i = 0; i < LOCAL_TABLE_SIZE; i++){
  	local_table[i] = 0;
  }

  for(int i = 0; i < CHOICE_TABLE_SIZE; i++){
  	choice_table[i] = 0;
  }

}

extern "C" void predict_branch(unsigned long long ip, unsigned long long hist, unsigned char *pred)
{





    uint32_t ip_hash = ip & ((1 << CHOICE_HISTORY_BITS) - 1);
	uint32_t choice_hash = hist % CHOICE_HISTORY_SIZE;
	// choice_hash ^= ip_hash;
    int choice = (choice_table[choice_hash] >= ((CHOICE_MAX_COUNTER + 1)/2)) ? 1 : 0;
    // choice = 0;
    if(choice == 0){
  //   	uint32_t ip_hash1 = ip & ((1 << GLOBAL_HISTORY_BITS) - 1);
  //   	uint32_t global_hash = hist & ((1 << GLOBAL_HISTORY_BITS) - 1);
  //   	global_hash ^= ip_hash1;
		// *pred = (global_table[global_hash] >= ((GLOBAL_MAX_COUNTER + 1)/2)) ? 1 : 0;

    // 	uint32_t hash = ip % BIMODAL_TABLE_SIZE;
  		// hash |= ((hist%GSHARE_GLOBAL_TABLE_SIZE)<<BIMODAL_HISTORY_BITS);


    	//gshare
		 uint32_t hash = ip % BIMODAL_TABLE_SIZE;
		 uint32_t share = hash>>(BIMODAL_HISTORY_BITS-GSHARE_GLOBAL_HISTORY_BITS);
		 share ^= hist;
		 share %= GSHARE_GLOBAL_HISTORY_SIZE;
		 share = share<<(BIMODAL_HISTORY_BITS-GSHARE_GLOBAL_HISTORY_BITS);
		 uint32_t mask = (1<<(BIMODAL_HISTORY_BITS-GSHARE_GLOBAL_HISTORY_BITS+1))-1;
		 hash &= mask;
		 hash |= share;
		 hash %= BIMODAL_TABLE_SIZE;

  		*pred = (bimodal_table[hash] >= ((MAX_COUNTER + 1)/2)) ? 1 : 0;

    }else{
    	uint32_t ip_hash2 = ip & ((1 << LOCAL_HISTORY_BITS) - 1);
    	uint32_t local_history_hash = ip % LOCAL_TABLE_SIZE;
		int local_hist = local_history_table[local_history_hash] % LOCAL_GLOBAL_HISTORY_SIZE;
		// local_hist ^= ip_hash2;
		*pred = (local_table[local_hist] >= ((LOCAL_MAX_COUNTER + 1)/2)) ? 1 : 0;
    }


//bimodal
  





    


}

extern "C" void update_branch(unsigned long long ip, unsigned long long hist, unsigned char taken){








//combined

	uint32_t ip_hash = ip & ((1 << CHOICE_HISTORY_BITS) - 1);

	uint32_t choice_hash = hist % CHOICE_HISTORY_SIZE;
    int choice = (choice_table[choice_hash] >= ((CHOICE_MAX_COUNTER + 1)/2)) ? 1 : 0;


	if(choice==0){
		
		if(taken==1 && (choice_table[choice_hash] > 0)){
			choice_table[choice_hash]--;
		}
		else if(taken==0 && (choice_table[choice_hash] < CHOICE_MAX_COUNTER)){
			choice_table[choice_hash]++;
		}
	}
	else if(choice==1){
		if(taken==1 && (choice_table[choice_hash] < CHOICE_MAX_COUNTER)){
			choice_table[choice_hash]++;
		}
		else if(taken==0 && (choice_table[choice_hash] > 0)){
			choice_table[choice_hash]--;
		}
	}


//bimodal
	// uint32_t hash = ip % BIMODAL_TABLE_SIZE;
 //  	hash |= ((hist%GSHARE_GLOBAL_TABLE_SIZE)<<BIMODAL_HISTORY_BITS);


//gshare
	 uint32_t hash = ip % BIMODAL_TABLE_SIZE;
	 uint32_t share = hash>>(BIMODAL_HISTORY_BITS-GSHARE_GLOBAL_HISTORY_BITS);
	 share ^= hist;
	 share %= GSHARE_GLOBAL_HISTORY_SIZE;
	 share = share<<(BIMODAL_HISTORY_BITS-GSHARE_GLOBAL_HISTORY_BITS);
	 uint32_t mask = (1<<(BIMODAL_HISTORY_BITS-GSHARE_GLOBAL_HISTORY_BITS+1))-1;
	 hash &= mask;
	 hash |= share;
	 hash %= BIMODAL_TABLE_SIZE;

  if (taken && (bimodal_table[hash] < MAX_COUNTER))
    bimodal_table[hash]++;
  else if ((taken == 0) && (bimodal_table[hash] > 0))
    bimodal_table[hash]--;


//global
	// uint32_t ip_hash1 = ip & ((1 << GLOBAL_HISTORY_BITS) - 1);
 //    uint32_t global_hash = hist & ((1 << GLOBAL_HISTORY_BITS) - 1);
 //    global_hash ^= ip_hash1;
	// if(taken && (global_table[global_hash] < GLOBAL_MAX_COUNTER))
	// 	global_table[global_hash]++;
	// else if((taken == 0) && (global_table[global_hash] > 0))
	// 	global_table[global_hash]--;

//local
	uint32_t ip_hash2 = ip & ((1 << LOCAL_HISTORY_BITS) - 1);
    uint32_t local_history_hash = ip % LOCAL_TABLE_SIZE;
	int local_hist = local_history_table[local_history_hash] % LOCAL_GLOBAL_HISTORY_SIZE;
	// local_hist ^= ip_hash2;
    if(taken && (local_table[local_hist] < LOCAL_MAX_COUNTER))
		local_table[local_hist]++;
	else if((taken == 0) && (local_table[local_hist] > 0))
		local_table[local_hist]--;
	local_hist = local_history_table[local_history_hash] % LOCAL_GLOBAL_HISTORY_SIZE;
	local_hist = ((local_hist & ((1<<LOCAL_HISTORY_BITS)-1)) << 1) | taken;
	local_history_table[local_history_hash] = local_hist;

}

