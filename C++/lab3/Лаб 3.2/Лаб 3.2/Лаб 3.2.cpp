#include <iostream>
#include <iomanip>
#include <locale.h>
#include <cmath>
#include <fstream>

int main()
{
    setlocale(LC_ALL, "Russian");

    double x, eps, a, s, q, temp; unsigned i;
    i = 0; eps = -1;
    std::cout << "Задача: найти сумму числового ряда и количество итераций цикла, вычисляющего эту сумму\n"
        << "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 3.2\n"
        << "Дата начала: 12.10.2022; Дата окончания:\n";
    do {
        if (i != 0) std::cout << "Неправильный eps: " << eps << '\n';
        std::cout << "Введите eps: "; std::cin >> eps;
        i++;
    } while (i < 3 && (eps < 0 || eps > 1e-10));
    if (i == 3) {
        std::cout << "Не был введён корректный eps, программа завершена\n";
        exit(1);
    }
    std::cout << "Введите x: "; std::cin >> x;
    i = 0; s = 0;
    a = 1; s += a;
    std::cout << '|' << std::setw(5) << 'i' << '|' << std::setw(40) << 'a' << '|' << std::setw(40) << 's' << '|' << '\n';
    std::cout << '|' << std::setw(5) << std::noshowpos << i << '|' << std::setw(40) << std::showpos << std::fixed << std::setprecision(15) << std::scientific << a << '|' << std::setw(40) << std::setprecision(15) << std::scientific << s << '|' << '\n';
    temp = x * x * x * x; //x^4
    do {
        q = temp / (4.0 * i + 1.0) / (4.0 * i + 2.0) / (4.0 * i + 3.0) / (4.0 * i + 4.0);
        a *= q;
        s += a;
        i++;
        std::cout << '|' << std::setw(5) << std::noshowpos << i << '|' << std::setw(40) << std::showpos << std::fixed << std::setprecision(15) << std::scientific << a << '|' << std::setw(40) << std::setprecision(15) << std::scientific << s << '|' << '\n';
    } while (abs(a) >= eps && i < 1000);
    std::cout << "Всего " << i + 1 << " шагов\n";

    std::fstream f;
    f.open("C:\\Users\\Александр\\source\\repos\\Лаб 3.1\\out.txt");
    i = 0; s = 0;
    a = 1; s += a;
    f << '|' << std::setw(5) << 'i' << '|' << std::setw(40) << 'a' << '|' << std::setw(40) << 's' << '|' << '\n';
    f << '|' << std::setw(5) << std::noshowpos << i << '|' << std::setw(40) << std::showpos << std::fixed << std::setprecision(15) << std::scientific << a << '|' << std::setw(40) << std::setprecision(15) << std::scientific << s << '|' << '\n';
    temp = x * x * x * x; //x^4
    do {
        q = temp / (4.0 * i + 1.0) / (4.0 * i + 2.0) / (4.0 * i + 3.0) / (4.0 * i + 4.0);
        a *= q;
        s += a;
        i++;
        f << '|' << std::setw(5) << std::noshowpos << i << '|' << std::setw(40) << std::showpos << std::fixed << std::setprecision(15) << std::scientific << a << '|' << std::setw(40) << std::setprecision(15) << std::scientific << s << '|' << '\n';
    } while (abs(a) >= eps && i < 1000);
    f << "Всего " << i + 1 << " шагов\n";

    f.close();
}
