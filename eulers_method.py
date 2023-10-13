import matplotlib.pyplot as plt
from math import sin, cos


def eulers_method(y_n, t_final, h):
    y_n = [y_n]
    t_n = [0]
    # h = (t_final - t_n[-1]) / n
    while t_n[-1] < t_final:
        y_n.append(y_n[-1] + (h * f(y_n[-1], t_n[-1])))
        t_n.append(t_n[-1] + h)
    return y_n, t_n


def f(y_n, t_n):
    return (cos(t_n) - y_n) / (t_n + 1)


if __name__ == "__main__":
    y_start = float(input("Starting y: "))
    t_final = float(input("Final t: "))
    h = float(input("Step size: "))
    ys, xs = eulers_method(y_start, t_final, h)
    print(ys)
    axes = plt.axes()
    axes.plot(xs, ys)
    plt.show()
