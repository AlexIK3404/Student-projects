/*Задание: P(x) = (22222.22*x^9 - 333.33*x^7 + 888*x^5) / (-6478*x^7 - 476.09324*x^6 - 421.3)
Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 1.1
Дата начала: 06.09.2022; Дата окончания: */

#include <iostream>
#include <iomanip>
#include <locale.h>

/*Представим первый полином как: x^5*(22222.22*x^4 - 333.33*x^2 + 888)
Представим второй полином как: x^6*(-6478*x - 476.09324) - 421.3*/

void main(void)
{   
    setlocale(LC_ALL, "Russian");

    double x, temp_x, p1, p2, p;
    std::cout << "P(x) = (22222.22*x^9 - 333.33*x^7 + 888*x^5) / (-6478*x^7 - 476.09324*x^6 - 421.3)\n"
              << "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 1.1\n"
              << "Дата начала: 06.09.2022; Дата окончания:\n";
    std::cout << "Введите x: ";
    std::cin >> x;
    temp_x = x * x; //x^2
    p1 = 22222.22 * temp_x * temp_x - 333.33 * temp_x + 888;
    std::cout << "1й шаг: p1 =" << std::setw(20) << std::setprecision(8) << p1 << "\n";
    temp_x = temp_x * temp_x * x; //x^5
    p1 = temp_x * p1;
    std::cout << "2й шаг: p1 =" << std::setw(20) << std::setprecision(8) << p1 << "\n";
    p2 = -6478 * x - 476.09324;
    std::cout << "3й шаг: p2 =" << std::setw(20) << std::setprecision(8) << p2 << "\n";
    temp_x = x * x * x; //x^3
    temp_x = temp_x * temp_x; //x^6
    p2 = temp_x * p2 - 421.3;
    std::cout << "4й шаг: p2 =" << std::setw(20) << std::setprecision(8) << p2 << "\n";
    p = p1 / p2;
    std::cout << "Результат для x =" << std::setw(10) << std::setprecision(3) << x
              << std::setw(20) << std::setprecision(8) << p << "\n";

}
