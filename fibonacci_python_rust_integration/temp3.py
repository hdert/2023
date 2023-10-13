def fibonacci(number: int) -> int:
    if number == 0:
        return 0
    if number == 1:
        return 1
    prevprev = 0
    prev = 1
    current = 1
    for _ in range(number - 1):
        current = prevprev + prev
        prev = current
    return current
