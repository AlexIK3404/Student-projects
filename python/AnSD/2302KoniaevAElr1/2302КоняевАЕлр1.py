class Node:
    def __init__(self, data):
        self.data = data
        self.prev = None
        self.next = None


class DoublyLinkedList:
    def __init__(self):
        self.head = None
        self.tail = None
        self.size = 0

def add_to_end(self, data):
    new_node = Node(data)
    if self.tail is None:
        self.head = self.tail = new_node
    else:
        new_node.prev = self.tail
        self.tail.next = new_node
        self.tail = new_node
    self.size += 1

def add_to_beginning(self, data):
    new_node = Node(data)
    if self.head is None:
        self.head = self.tail = new_node
    else:
        new_node.next = self.head
        self.head.prev = new_node
        self.head = new_node
    self.size += 1

def delete_last(self):
    if self.tail is None:
        return None
    data = self.tail.data
    if self.head == self.tail:
        self.head = self.tail = None
    else:
        self.tail = self.tail.prev
        self.tail.next = None
    self.size -= 1
    return data

def delete_first(self):
    if self.head is None:
        return None
    data = self.head.data
    if self.head == self.tail:
        self.head = self.tail = None
    else:
        self.head = self.head.next
        self.head.prev = None
    self.size -= 1
    return data

def add_by_index(self, index, data):
    if index < 0 or index > self.size:
        raise Exception("Index out of range")
    if index == 0:
        add_to_beginning(self, data)
        return
    if index == self.size:
        add_to_end(self, data)
        return
    new_node = Node(data)
    curr_node = self.head
    for i in range(index - 1):
        curr_node = curr_node.next
    new_node.prev = curr_node
    new_node.next = curr_node.next
    curr_node.next.prev = new_node
    curr_node.next = new_node
    self.size += 1

def get_by_index(self, index):
    if index < 0 or index >= self.size:
        raise Exception("Index out of range")
    curr_node = self.head
    for i in range(index):
        curr_node = curr_node.next
    return curr_node.data

def delete_by_index(self, index):
    if index < 0 or index >= self.size:
        raise Exception("Index out of range")
    if index == 0:
        return delete_first(self)
    if index == self.size - 1:
        return delete_last(self)
    curr_node = self.head
    for i in range(index):
        curr_node = curr_node.next
    data = curr_node.data
    curr_node.prev.next = curr_node.next
    curr_node.next.prev = curr_node.prev
    self.size -= 1
    return data

def get_size(self):
    return self.size

def clear(self):
    self.head = None
    self.tail = None
    self.size = 0

def replace_at_index(self, index, data):
    if index < 0 or index >= self.size:
        raise IndexError("Index out of range")
    current = self.head
    for _ in range(index):
        current = current.next
    current.data = data

def is_empty(self):
    return self.size == 0

def reverse(self):
    current = self.head
    while current is not None:
        temp = current.next
        current.next = current.prev
        current.prev = temp
        current = temp
    self.head, self.tail = self.tail, self.head

def insert_list_at_index(self, index, other_list):
    if index < 0 or index > self.size:
        raise IndexError("Index out of range")
    if is_empty(other_list):
        return
    if index == 0:
        other_list.tail.next = self.head
        if self.head is not None:
            self.head.prev = other_list.tail
        else:
            self.tail = other_list.tail
        self.head = other_list.head
    elif index == self.size:
        self.tail.next = other_list.head
        other_list.head.prev = self.tail
        self.tail = other_list.tail
    else:
        current = self.head
        for _ in range(index):
            current = current.next
        other_list.head.prev = current.prev
        other_list.tail.next = current
        current.prev.next = other_list.head
        current.prev = other_list.tail
    self.size += other_list.size

def insert_list_at_end(self, other_list):
    insert_list_at_index(self, self.size, other_list)

def insert_list_at_start(self, other_list):
    insert_list_at_index(self, 0, other_list)

def _is_sublist(self, start_node, other_list):
    current = start_node
    other_current = other_list.head
    while current is not None and other_current is not None:
        if current.data != other_current.data:
            return False
        current = current.next
        other_current = other_current.next
    return other_current is None

def ensure_list_contains(self, other_list):
    if is_empty(other_list):
        return False
    current = self.head
    while current is not None:
        if _is_sublist(self, current, other_list):
            return True
        current = current.next
    return False

def find_first_occurrence(self, other_list):
    if is_empty(other_list):
        return -1
    index = 0
    current = self.head
    while current is not None:
        if _is_sublist(self, current, other_list):
            return index
        current = current.next
        index += 1
    return -1

def find_last_occurrence(self, other_list):
    if is_empty(other_list):
        return -1
    index = self.size - 1
    current = self.tail
    while current is not None:
        if _is_sublist(self, current, other_list):
            return index - other_list.size + 1
        current = current.prev
        index -= 1
    return -1

def _swap_nodes(self, node1, node2):
    if node1.next == node2:
        if node1.prev != None: node1.prev.next = node2
        if node2.next != None: node2.next.prev = node1
        node1.next = node2.next
        node2.prev = node1.prev
        node2.next = node1
        node1.prev = node2
    else:
        node1.prev.next = node2
        node2.next.prev = node1
        node1.next.prev = node2
        node2.prev.next = node1
        node1.next, node2.next = node2.next, node1.next
        node1.prev, node2.prev = node2.prev, node1.prev


def get_node_by_index(self, index):
    curr_node = self.head
    for i in range(index):
        curr_node = curr_node.next
    return curr_node


def swap_elements_at_index(self, index1, index2):
    if index1 < 0 or index1 >= self.size or index2 < 0 or index2 >= self.size:
        raise IndexError("Index out of range")
    if index1 == index2:
        return
    if index1 > index2:
        index1, index2 = index2, index1
    node1 = get_node_by_index(self, index1)
    node2 = get_node_by_index(self, index2)
    _swap_nodes(self, node1, node2)

def print_list(self):
    curr_node = self.head
    print('Список:')
    print('[ ', end='')
    while curr_node != None:
        print(curr_node.data, ' ', sep='', end='')
        curr_node = curr_node.next
    print(']')

print('Введите значение первого элемента списка')
data = input()
linked_list = DoublyLinkedList()
add_to_end(linked_list, data)
while True:
    print('Введите запрос:')
    print('1. Добавление элемента', '2. Удаление элемента', '3. Получение элемента по индексу',
          '4. Получение размера списка',
          '5. Удаление списка', '6. Замена элементов', '7. Проверка на пустоту', '8. Вставка другого списка',
          '9. Проверка на содержание другого списка',
          '10. Поиск вхождения другого списка', '11. Обмен двух элементов списка по индексам', sep='\n')
    button1 = input()
    if button1 == '1':
        print('1. Добавление в конец', '2. Добавление в начало', '3. Добавление по индексу', sep='\n')
        button2 = input()
        if button2 == '1':
            while True:
                print('Введите значение для вставки:')
                n = input()
                add_to_end(linked_list, n)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '2':
            while True:
                print('Введите значение для вставки:')
                n = input()
                add_to_beginning(linked_list, n)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '3':
            while True:
                print('Введите значение для вставки:')
                n = input()
                print('Введите индекс для вставки:')
                ind = int(input())
                add_by_index(linked_list, ind, n)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        else:
            print('Неверное значение')
    elif button1 == '2':
        print('1. Удаление последнего элемента', '2. Удаление первого элемента', '3. Удаление по индексу', sep='\n')
        button2 = input()
        if button2 == '1':
            while True:
                delete_last(linked_list)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '2':
            while True:
                delete_first(linked_list)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '3':
            while True:
                print('Введите индекс для удаления:')
                ind = int(input())
                delete_by_index(linked_list, ind)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        else:
            print('Неверное значение')
    elif button1 == '3':
        while True:
            print('Введите индекс элемента:')
            ind = int(input())
            print(get_by_index(linked_list, ind))
            print('Желаете повторить? y/n')
            break_condition = input()
            if break_condition == 'n': break
    elif button1 == '4':
        print('Размер списка:', get_size(linked_list))
    elif button1 == '5':
        clear(linked_list)
        print('Список удалён')
    elif button1 == '6':
        print('1. Замена элемента по индексу на передаваемый элемент',
              '2. Замена порядка элементов в списке на обратный', sep='\n')
        button2 = input()
        if button2 == '1':
            while True:
                print('Введите значение для замены:')
                n = input()
                print('Введите индекс для замены:')
                ind = int(input())
                replace_at_index(linked_list, ind, n)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '2':
            while True:
                reverse(linked_list)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        else:
            print('Неверное значение')
    elif button1 == '7':
        print(is_empty(linked_list))
    elif button1 == '8':
        print('1. Вставка начиная с индекса', '2. Вставка в конец', '3. Вставка в начало', sep='\n')
        button2 = input()
        if button2 == '1':
            while True:
                print('Введите значения второго списка через пробел:')
                other_list = input().split()
                other_linked_list = DoublyLinkedList()
                for s in other_list:
                    add_to_end(other_linked_list, s)
                print('Введите индекс для вставки:')
                ind = int(input())
                insert_list_at_index(linked_list, ind, other_linked_list)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '2':
            while True:
                print('Введите значения второго списка через пробел:')
                other_list = input().split()
                other_linked_list = DoublyLinkedList()
                for s in other_list:
                    add_to_end(other_linked_list, s)
                insert_list_at_end(linked_list, other_linked_list)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '3':
            while True:
                print('Введите значения второго списка через пробел:')
                other_list = input().split()
                other_linked_list = DoublyLinkedList()
                for s in other_list:
                    add_to_end(other_linked_list, s)
                insert_list_at_start(linked_list, other_linked_list)
                print_list(linked_list)
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        else:
            print('Неверное значение')
    elif button1 == '9':
        while True:
            print('Введите значения второго списка через пробел:')
            other_list = input().split()
            other_linked_list = DoublyLinkedList()
            for s in other_list:
                add_to_end(other_linked_list, s)
            print(ensure_list_contains(linked_list, other_linked_list))
            print('Желаете повторить? y/n')
            break_condition = input()
            if break_condition == 'n': break
    elif button1 == '10':
        print('1. Поиск первого вхождения', '2. Поиск последнего вхождения', sep='\n')
        button2 = input()
        if button2 == '1':
            while True:
                print('Введите значения второго списка через пробел:')
                other_list = input().split()
                other_linked_list = DoublyLinkedList()
                for s in other_list:
                    add_to_end(other_linked_list, s)
                print('Индекс первого вхождения:', find_first_occurrence(linked_list, other_linked_list))
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        elif button2 == '2':
            while True:
                print('Введите значения второго списка через пробел:')
                other_list = input().split()
                other_linked_list = DoublyLinkedList()
                for s in other_list:
                    add_to_end(other_linked_list, s)
                print('Индекс последнего вхождения:', find_last_occurrence(linked_list, other_linked_list))
                print('Желаете повторить? y/n')
                break_condition = input()
                if break_condition == 'n': break
        else:
            print('Неверное значение')
    elif button1 == '11':
        while True:
            print('Введите первый индекс:')
            ind1 = int(input())
            print('Введите второй индекс:')
            ind2 = int(input())
            swap_elements_at_index(linked_list, ind1, ind2)
            print_list(linked_list)
            print('Желаете повторить? y/n')
            break_condition = input()
            if break_condition == 'n': break
    else:
        print('Неверное значение')
    print('Желаете повторить? y/n')
    break_condition = input()
    if break_condition == 'n': break
