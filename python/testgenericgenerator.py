#!/usr/bin/python
import random
from genericgenerator import GenericGenerator
import unittest

class TestGenericGenerator(unittest.TestCase):
    "test the generic generator"
    def setUp(self):
        self.defaultseed=1
        self.gen = GenericGenerator(self.defaultseed)
        self.teststructure=[
                {           'max':30, 'content':"foo"},
                {'min': 31, 'max':66, 'content':"bar"},
                {'min': 67,           'content':"baz"},
                     ]

    def test_random_seed(self):
        gen =GenericGenerator()
        self.assertTrue(gen.seed>= 1 and gen.seed <= 1000000, "between 1 and 1000000") 
        
    def test_known_seed(self):
        self.assertEqual(self.gen.seed,self.defaultseed, "set to a known value {0} is {1}".format(self.gen.seed, self.defaultseed)) 

    def test_seed_reset(self):
        newrandom=random.randint(1,100)
        self.assertEqual( newrandom, 14  , "first random for seed {0} is {1} which is 14".format(self.gen.seed, newrandom))
        newrandom=random.randint(1,100)
        self.assertEqual( newrandom, 85  , "first random for seed {0} is {1} which is 85".format(self.gen.seed, newrandom))

        self.gen.reset_seed();

        newrandom=random.randint(1,100)
        self.assertEqual( newrandom, 14  , "first random for seed {0} is {1} which is 14".format(self.gen.seed, newrandom))
        newrandom=random.randint(1,100)
        self.assertEqual( newrandom, 85  , "first random for seed {0} is {1} which is 85".format(self.gen.seed, newrandom))

    def test_rand_from_array(self):
        testarray=[ [1,2],[2,3],[3,4] ]
        testvalue= self.gen.rand_from_array(testarray )
        self.assertEqual( testvalue, [1,2], "which item is selected? {0}".format(testvalue ))
        testvalue= self.gen.rand_from_array(testarray )
        self.assertEqual( testvalue, [3,4], "which item is selected? {0}".format(testvalue ))
        testvalue= self.gen.rand_from_array(testarray )
        self.assertEqual( testvalue, [3,4], "which item is selected? {0}".format(testvalue ))
        self.gen.reset_seed();
        testvalue= self.gen.rand_from_array(testarray )
        self.assertEqual( testvalue, [1,2], "which item is selected? {0}".format(testvalue ))
        testvalue= self.gen.rand_from_array(testarray )
        self.assertEqual( testvalue, [3,4], "which item is selected? {0}".format(testvalue ))
        testvalue= self.gen.rand_from_array(testarray )
        self.assertEqual( testvalue, [3,4], "which item is selected? {0}".format(testvalue ))

    def test_roll_from_array_low(self):
        "test the low end of a stat"
        result = self.gen.roll_from_array(-10,self.teststructure)["content"]
        self.assertEqual(result, "foo", "roll of -10 gives us {0}".format(result))

        result = self.gen.roll_from_array(30,self.teststructure)["content"]
        self.assertEqual(result, "foo", "roll of 30 gives us {0}".format(result))

    def test_roll_from_array_mid(self):
        "test the mid section of a stat"
        result = self.gen.roll_from_array(31,self.teststructure)["content"]
        self.assertEqual(result, "bar", "roll of 31 gives us {0}".format(result))

        result = self.gen.roll_from_array(50,self.teststructure)["content"]
        self.assertEqual(result, "bar", "roll of 50 gives us {0}".format(result))

        result = self.gen.roll_from_array(66,self.teststructure)["content"]
        self.assertEqual(result, "bar", "roll of 66 gives us {0}".format(result))

    def test_roll_from_array_mid(self):
        "test the mid section of a stat"
        result = self.gen.roll_from_array(67,self.teststructure)["content"]
        self.assertEqual(result, "baz", "roll of 67 gives us {0}".format(result))

        result = self.gen.roll_from_array(1000,self.teststructure)["content"]
        self.assertEqual(result, "baz", "roll of 1000 gives us {0}".format(result))

    def test_d(self):
        result=self.gen.d(100)
        self.assertEqual(result, 14, "roll of d(100) gives us {0}".format(result))
        result=self.gen.d(100)
        self.assertEqual(result, 85, "roll of d(100) gives us {0}".format(result))



if __name__ == '__main__':
    unittest.main()




