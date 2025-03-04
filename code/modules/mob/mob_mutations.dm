/// Helper to add mutation. It automatically adds movespeed modifier. Use this instead of 'mutations.Add'
/mob/proc/add_mutation(mutation)
	mutations.Add(mutation)
	switch(mutation)
		if(MUTATION_FAT)
			add_movespeed_modifier(/datum/movespeed_modifier/mutation_fat)
		if(mRun)
			add_movespeed_modifier(/datum/movespeed_modifier/mutation_run)

/// Helper to add mutation. It automatically adds movespeed modifier. Use this instead of 'mutations.Remove'
/mob/proc/remove_mutation(mutation)
	mutations.Remove(mutation)
	switch(mutation)
		if(MUTATION_FAT)
			remove_movespeed_modifier(/datum/movespeed_modifier/mutation_fat)
		if(mRun)
			remove_movespeed_modifier(/datum/movespeed_modifier/mutation_run)
