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


    def parse_name(self,data):
        newname={'pre':'','root':'','post':''}
        for part in ('title', 'pre', 'root', 'post', 'trailer'):
            if part in data:
                if part+"_chance" in data and data[part+"_chance"] > self.d(100):
                    newname[part]=self.rand_from_array(data[part])
                elif part+"_chance" not in data:
                    newname[part]=self.rand_from_array(data[part])
        newname['content']= "{0}{1}{2}".format(newname['pre'], newname['root'], newname['post'])
        if 'title' in newname:
            newname['content']= newname['title']+ " "+newname['content']
        return newname









