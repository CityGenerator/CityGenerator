#!/usr/bin/python

import random

class GenericGenerator:
    "the generic generator is the core of all other generators"

    def __init__(self,seed=random.randint(1,1000000)):
        "initialize a simple generator, usually by setting the default seed"
        self.seed=seed
        random.seed(self.seed)

    def reset_seed(self):
        "resets the randomness, making it less random and more predictable"
        random.seed(self.seed)

    def rand_from_array(self,array):
        "select an item from an array (a simple wrapper for consistency)."
        return random.choice(array)

    def roll_from_array(self,roll,array):
        "select an option from an array where the roll falls between the min and max"
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

        # return the last array if one doesn't match.
        return array[-1];


    def d(self,dice):
        "yet another simple wrapper to emulate rolling a d6"
        #FIXME needs to accept "3d4" formats as well
        return random.randint(1,dice);



