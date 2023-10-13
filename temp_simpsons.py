from math import sqrt
import numpy as np


def function(x):
    return sqrt(4-x**2)


start = 0
end = 2
num = 6
delta_x = (end - start) / num

print(((function(start)) + sum([(2 * function(num)) if i % 2 else (4 * function(num))
      for i, num in enumerate(np.arange(start + delta_x, end, delta_x))]) + (function(end))) * delta_x/3)
