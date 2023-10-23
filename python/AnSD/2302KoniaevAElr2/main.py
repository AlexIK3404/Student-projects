import time
from random import randint

def selection_sort(arr):
    for i in range(len(arr)):
        minimum = i
        for j in range(i + 1, len(arr)):
            if arr[j] < arr[minimum]:
                minimum = j
        arr[minimum], arr[i] = arr[i], arr[minimum]
    return arr

def insertion_sort(arr):
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and key < arr[j]:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
    return arr

def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

def merge_sort(arr):
    if len(arr) > 1:
        mid = len(arr) // 2
        left_half = arr[:mid]
        right_half = arr[mid:]

        merge_sort(left_half)
        merge_sort(right_half)

        i = j = k = 0

        while i < len(left_half) and j < len(right_half):
            if left_half[i] < right_half[j]:
                arr[k] = left_half[i]
                i += 1
            else:
                arr[k] = right_half[j]
                j += 1
            k += 1

        while i < len(left_half):
            arr[k] = left_half[i]
            i += 1
            k += 1

        while j < len(right_half):
            arr[k] = right_half[j]
            j += 1
            k += 1

    return arr

def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    else:
        pivot = arr[0]
        left = []
        right = []
        for i in range(1, len(arr)):
            if arr[i] < pivot:
                left.append(arr[i])
            else:
                right.append(arr[i])
        return quick_sort(left) + [pivot] + quick_sort(right)

def shell_sort_s(arr):
    n = len(arr)
    gap = 1
    gaps = []
    k = 1
    while gap < n:
        gaps.append(gap)
        gap = 4**k + 3 * 2**(k-1) + 1
        k += 1
    gaps.reverse()

    for gap in gaps:
        for i in range(gap, n):
            temp = arr[i]
            j = i
            while j >= gap and arr[j - gap] > temp:
                arr[j] = arr[j - gap]
                j -= gap
            arr[j] = temp

    return arr

def shell_sort_x(arr):
    n = len(arr)
    gap = 1
    gaps = []
    k = 1
    while gap < n:
        gaps.append(gap)
        gap = 2**k - 1
        k += 1
    gaps.reverse()

    for gap in gaps:
        for i in range(gap, n):
            temp = arr[i]
            j = i
            while j >= gap and arr[j - gap] > temp:
                arr[j] = arr[j - gap]
                j -= gap
            arr[j] = temp

    return arr

def shell_sort(arr):
    n = len(arr)
    k = 1
    gap = int(n/2**k)
    gaps = []
    while gap != 0:
        gaps.append(gap)
        k += 1
        gap = int(n/2**k)

    for gap in gaps:
        for i in range(gap, n):
            temp = arr[i]
            j = i
            while j >= gap and arr[j - gap] > temp:
                arr[j] = arr[j - gap]
                j -= gap
            arr[j] = temp
    return arr

def heapify(arr, n, i):
    largest = i
    left = 2 * i + 1
    right = 2 * i + 2

    if left < n and arr[i] < arr[left]:
        largest = left

    if right < n and arr[largest] < arr[right]:
        largest = right

    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        heapify(arr, n, largest)

def heap_sort(arr):
    n = len(arr)

    for i in range(n // 2 - 1, -1, -1):
        heapify(arr, n, i)

    for i in range(n - 1, 0, -1):
        arr[i], arr[0] = arr[0], arr[i]
        heapify(arr, i, 0)

    return arr

def insertion_sort(arr, left=0, right=None):
    if right is None:
        right = len(arr) - 1

    for i in range(left + 1, right + 1):
        key_item = arr[i]
        j = i - 1
        while j >= left and arr[j] > key_item:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key_item

    return arr

def merge(left, right):
    if not left:
        return right

    if not right:
        return left

    if left[0] < right[0]:
        return [left[0]] + merge(left[1:], right)

    return [right[0]] + merge(left, right[1:])

def timsort(arr):
    min_run = 32
    n = len(arr)

    for i in range(0, n, min_run):
        insertion_sort(arr, i, min((i + min_run - 1), n - 1))

    size = min_run
    while size < n:
        for start in range(0, n, size * 2):
            midpoint = start + size - 1
            end = min((start + size * 2 - 1), (n-1))
            merged_array = merge(
                left=arr[start:midpoint + 1],
                right=arr[midpoint + 1:end + 1]
            )
            arr[start:start + len(merged_array)] = merged_array

        size *= 2

    return arr

import math

def partition(arr, low, high):
    pivot = arr[high]
    i = low - 1
    for j in range(low, high):
        if arr[j] <= pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1

def introsort(arr, depth_limit=None):
    if depth_limit is None:
        depth_limit = math.log(len(arr)) * 2

    n = len(arr)

    if n <= 1:
        return arr

    elif depth_limit == 0:
        return heap_sort(arr)

    else:
        pivot = partition(arr, 0, n - 1)
        left = introsort(arr[:pivot], depth_limit - 1)
        right = introsort(arr[pivot + 1:], depth_limit - 1)
        arr[:pivot] = left
        arr[pivot + 1:] = right
        return arr

import sys

def print_array(array):
    if len(array) > 100:
        print("Первые 100 элементов массива:")
        print(array[:101])
    else: print(array)

array = []

while True:
    print("1. Добавить 1 элемент в массив", "2. Добавить 10 случайных элементов в массив",
         "3. Добавить 100 случайных элементов в массив", "4. Добавить 1000 случайных элементов в массив", sep='\n')
    button = input()
    if button == '1':
        print("Введите число:")
        array.append(int(input()))
        print_array(array)
    elif button == '2':
        for _ in range(10):
            array.append(randint(1, 1000))
        print_array(array)
    elif button == '3':
        for _ in range(100):
            array.append(randint(1, 1000))
        print_array(array)
    elif button == '4':
        for _ in range(1000):
            array.append(randint(1, 1000))
        print_array(array)
    else:
        print("Неверное значение")
    print("Продолжить добавление элементов? y/n")
    flag = input()
    if flag == 'n': break

sys.setrecursionlimit(len(array)**2)
while True:
    print("Выберите алгоритм сортировки:")
    print("1. Сортировка выбором", "2. Сортировка вставками", "3. Сортировка пузырьком", "4. Сортировка слиянием",
          "5. Быстрая сортировка", "6. Сортировка Шелла (Последовательность Сэджвика)", "7. Сортировка Шелла (Последовательность Хиббарда)",
          "8. Сортировка Шелла (Классическая последовательность)", "9. Пирамидальная сортировка", "10. Timsort", "11. IntroSort", sep='\n')
    button = input()
    if button == '1':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", selection_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '2':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", insertion_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '3':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", bubble_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '4':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", merge_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '5':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", quick_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '6':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", shell_sort_s(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '7':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", shell_sort_x(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '8':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", shell_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '9':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", heap_sort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '10':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", timsort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    elif button == '11':
        start = time.time()
        print("До 100 первых элементов отсортированного массива:", introsort(array)[:101], sep='\n')
        end = time.time()
        print("Время работы:", end - start, "s")
    else:
        print("Неверное значение")
    print("Желаете повторить? y/n")
    flag = input()
    if flag == 'n': break
