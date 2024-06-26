﻿#include <iostream>
#include <iomanip>
#include <fstream>

const unsigned n = 200, m = 100;

void SizeArr(unsigned& a, unsigned& b) {
	std::fstream f; f.open("in.txt", std::ios::in);
	f >> a >> b;
	unsigned size = 0, i = 0, j = 0;
	char tmp;
	if (a > n) a = n;
	if (b > m) b = m;
	f >> tmp >> tmp;
	unsigned count_ws = 0; bool flag = false, ws_flag = false;
	do {
		f >> std::noskipws >> tmp;
		if (tmp == ' ') {
			if (ws_flag == false) count_ws += 1;
			ws_flag = true;
		}
		if (tmp == '\n') {
			if (count_ws + 1 < b && flag == true) b = count_ws + 1;
			size++;
			count_ws = 0; flag = false; ws_flag = false;
		}
		if (tmp != ' ' && tmp != '\n') {
			flag = true;
			ws_flag = false;
		}
		if (size == a) break;
	} while (f.eof() != true);
	if (size < a) a = size;
	f.close();
}

void InpArr(int A[n][m], unsigned a, unsigned b, unsigned& m, unsigned& k) {
	char tmp;
	std::fstream g; g.open("in.txt", std::ios::in);
	std::fstream f; f.open("InpArr.txt", std::ios::out);
	g >> tmp >> tmp;
	g >> m >> k;
	if (m > b) m = b;
	if (k > a) k = a;
	f << a << ' ' << b << '\n' << m << ' ' << k << '\n';
	for (unsigned i = 0; i < a; i++) {
		for (unsigned j = 0; j < b; j++) {
			g >> A[i][j];
			f << std::left << std::setw(4) << A[i][j] << ' ';
		}
		f << '\n';
	}
	g.close();
	f.close();
}

void Process(int A[n][m], unsigned a, unsigned b, unsigned m, unsigned k, int& max) {
	for (unsigned i = 0; i < b; i++) {
		if (A[k - 1][i] > max) max = A[k - 1][i];
	}
	for (unsigned i = k; i < a - 1; i++) {
		if (A[i][m - 1] > max) max = A[i][m - 1];
	}
	for (unsigned i = 0; i < b; i++) {
		if (A[a - 1][i] > max) max = A[a - 1][i];
	}
}

void OutRes(int max) {
	std::fstream f; f.open("out.txt", std::ios::out);
	f << "Задача: Найти наибольший элемент заштрихованной области таблицы размера N*N\n"
		<< "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 4.2\n"
		<< "Дата начала: 09.11.2022; Дата окончания:\n\n";
	f << "Res: " << max;
	f.close();
}

int main()
{
	int A[n][m]; unsigned a, b, m, k; int max = -2147483648;
	SizeArr(a, b);
	InpArr(A, a, b, m, k);
	Process(A, a, b, m, k, max);
	OutRes(max);
}