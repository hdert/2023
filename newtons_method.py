from math import tan


def main():
    start = float(input("Start: "))
    steps = int(input("Steps: "))
    x = start
    for step in range(steps):
        print(f"Step: {step} Value: {x} Delta: {f(x)/f_prime(x)}")
        x -= f(x)/f_prime(x)
    print(f"Step: {step+1} Value: {x}")


def f(x):
    R = 6378000
    return tan(x) - x - 1/(2*R)


def f_prime(x):
    return tan(x)**2


if __name__ == "__main__":
    main()
