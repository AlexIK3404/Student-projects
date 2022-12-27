/*Задание: P(x) = (22222.22*x^9 - 333.33*x^7 + 888*x^5) / (-6478*x^7 - 476.09324*x^6 - 421.3)
Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 2.1
Дата начала: 06.09.2022; Дата окончания: */

#include <iostream>
#include <iomanip>
#include <locale.h>

void main(void)
{
    setlocale(LC_ALL, "Russian");

    double x, temp_x, p;
    std::cout << "P(x) = (22222.22*x^9 - 333.33*x^7 + 888*x^5) / (-6478*x^7 - 476.09324*x^6 - 421.3)\n"
        << "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 2.1\n"
        << "Дата начала: 06.09.2022; Дата окончания:\n";
    std::cout << "Введите x: ";
    std::cin >> x;
    temp_x = x * x * x; //x^3
    p = (22222.22 * (temp_x * temp_x * temp_x) - 333.33 * (temp_x * temp_x * x) + 888 * (temp_x * x * x))
        / ((temp_x * temp_x) * (-6478 * x - 476.09324) - 421.3);
    std::cout << "Результат для x =" << std::setw(10) << std::setprecision(3) << x
        << std::setw(20) << std::setprecision(8) << p << "\n";

}