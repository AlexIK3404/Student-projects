﻿/*Задание: P(x) = -6478*x^7 - 476.09324*x^6 - 421.3
Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 3.1
Дата начала: 06.09.2022; Дата окончания: */

#include <stdio.h>
#include <iomanip>
#include <locale.h>

void main(void)
{
    setlocale(LC_ALL, "Russian");

    long float x, temp_x, p1, p2, p;
    printf("%s\n%s\n%s\n", "P(x) = -6478 * x ^ 7 - 476.09324 * x ^ 6 - 421.3",
           "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 3.1",
           "Дата начала: 06.09.2022; Дата окончания:");
    printf("%s", "Введите x: ");
    scanf("%lf", &x);
    temp_x = x * x; //x^2
    p1 = 22222.22 * temp_x * temp_x - 333.33 * temp_x + 888;
    printf("%s%20.8f\n", "1й шаг: p1 =", p1);
    temp_x = temp_x * temp_x * x; //x^5
    p1 = temp_x * p1;
    printf("%s%20.8f\n", "2й шаг: p1 =", p1);
    p2 = -6478 * x - 476.09324;
    printf("%s%20.8f\n", "3й шаг: p2 =", p2);
    temp_x = x * x * x; //x^3
    temp_x = temp_x * temp_x; //x^6
    p2 = temp_x * p2 - 421.3;
    printf("%s%20.8f\n", "4й шаг: p2 =", p2);
    p = p1 / p2;
    printf("%s%10.3lf%20.8lf\n", "Результат для x =", x, p);

}