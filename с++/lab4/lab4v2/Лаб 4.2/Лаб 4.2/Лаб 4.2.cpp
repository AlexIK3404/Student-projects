﻿#include <fstream>
#include <iomanip>

int main()
{
	int L;
	float tmp;
	unsigned ind = 1;
	std::fstream f, g; f.open("in2.txt", std::ios::in); g.open("out.txt", std::ios::out);
	g << "Задача: Для последовательности из n вещественных значений a_i создать новую последовательность,\n"
		<< "состоящую из различных элементов исходной последовательности и входящих в нее в исходном порядке следования.\n"
		<< "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 4.2\n"
		<< "Дата начала: 26.10.2022; Дата окончания:\n\n";
	if (f.is_open() == false) g << "Err open_in";
	else {
		if (f.eof()) g << "Eof";
		else {
			unsigned i = 0; while (!f.eof()) {
				f >> tmp;
				i++;
			}
			L = i;
			f.close();
		}
	}
	float* pA = new float[L + 1];
	f.open("in2.txt", std::ios::in);
	if (f.is_open() == false) g << "Err open_in";
	else {
		for (unsigned i = 0; i < L; ++i) {
			f >> *(pA + i);
		}
	}
	f.close();
	g << L << std::endl; for (unsigned i = 0; i < L; i++) g << *(pA + i) << std::endl; g << std::endl;
	int basic_L  = L;
	float *pB = new float[L];
	if (L > 0) *(pB + 0) = *(pA + 0);
	for (unsigned i = 1; i < basic_L; i++) {
		bool flag = false;
		for (unsigned l = 0; l != basic_L - 1; ++l) {
			if (*(pA + i) == *(pB + l)) {
				flag = true;
				break;
			}
		}
		if (flag == false) {
			*(pB + ind) = *(pA + i);
			ind++;
			L++;
		}
		L--;
	}
	g << L << std::endl; for (unsigned i = 0; i < L; i++) g << *(pB + i) << std::endl;
	g.close();
	delete[]pA;
	delete[]pB;
}