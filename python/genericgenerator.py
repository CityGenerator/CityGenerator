#!/usr/bin/python

import random

class GenericGenerator:
    "a generic class"
    seed = None
    def __init__(self,seed=random.randint(1,1000000)):
        #FIXME check to see if seed 
        # is a valid value
        self.seed=seed
        random.seed(self.seed)

    def reset_seed(self):
        random.seed(self.seed)

    def rand_from_array(self,array):
        return random.choice(array)

    def roll_from_array(self,roll,array):
        "select an option from an array"
        for option in array:
            if  'min' in option and 'max' in option:
                if option['min'] <= roll and option['max'] >= roll:
                    return option
            elif 'min' in option:
                if option['min'] <= roll:
                    return option
            elif 'max' in option:
                if option['max'] >= roll:
                    return option

        return array[-1];

    def d(self,dice):
        return random.randint(1,dice);



