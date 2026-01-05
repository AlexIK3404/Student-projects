#include <iostream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <string>
#include <locale.h>

const int n = 100;
const double pi = 3.14159265358979323846;

void Interpolation(float x1, float y1, float x2, float y2, float& k, float& b) {
	k = (y1 - y2) / (x1 - x2);
	b = y1 - x1 * k;
}

void SizeArr(unsigned& a, std::fstream& p) {
	std::fstream f; f.open("in.txt", std::ios::in);

	if (f.is_open() && p.is_open()) {
		f >> a;
		unsigned size = 0;
		char tmp;
		if (a > n) a = n;
		unsigned count_ws = 0; bool flag = false, ws_flag = false;
		f >> std::noskipws >> tmp;

		do {
			f >> std::noskipws >> tmp;
			if (tmp != ' ' && tmp != '\n') {
				flag = true;
				ws_flag = false;
			}
			if (tmp == ' ') {
				if (flag == true && ws_flag == false) count_ws += 1;
				ws_flag = true;
			}
			if (tmp == '\n') {
				if (flag == true && count_ws != 0) {
					size++;
					if (count_ws == 1) p << "Данные корректны" << '\n';
					if (count_ws > 1) p << "Количество чисел в строке больше 2" << '\n';
				}
				else {
					if (flag == false) p << "Обнаружена пустая строка" << '\n';
					else p << "Недостаточно данных" << '\n';
				}
				count_ws = 0; flag = false; ws_flag = false;
			}
			if (f.eof()) {
				if (flag == true && count_ws == 1) {
					size++;
					p << "Данные корректны" << '\n';
				}
				break;
			}
			if (size == a) break;
		} while (f.eof() != true);
		if (size < a) a = size;
		p << '\n';
		f.close();
	}
	else {
		if (f.is_open() == false) std::cout << "Не удалось открыть входной файл";
		if (p.is_open() == false) std::cout << "Не удалось открыть файл протокола";
	}
}

void InpArr(float A[n][2], unsigned a, std::fstream& p) {
	std::fstream g; g.open("in.txt", std::ios::in);

	if (g.is_open() && p.is_open()) {
		int num; char tmp;
		bool flag = false, ws_flag = false, break_flag = false;
		unsigned count_ws = 0;
		unsigned position;
		g >> num;
		p << a << '\n' << std::flush;
		unsigned i = 0;
		while (g.eof() != true) {
			if (i == a) break;
			position = g.tellg();
			break_flag = false;
			while (1) {
				g >> std::noskipws >> tmp;
				if (tmp != ' ' && tmp != '\n') {
					flag = true;
					ws_flag = false;
				}
				if (tmp == ' ') {
					if (flag == true && ws_flag == false) count_ws += 1;
					ws_flag = true;
				}
				if (tmp == '\n') {
					if (count_ws != 0) {
						g.seekg(position, std::ios::beg);
						for (unsigned q = 0; q < 2; q++) {
							g >> std::skipws >> A[i][q];
							p << std::left << std::setw(4) << A[i][q] << ' ' << std::flush;
						}
						p << '\n';
						tmp = ' ';
						while (tmp != '\n') {
							g >> std::noskipws >> tmp;
							if (g.eof()) break;
						}
						i++;
						break_flag = true;
					}
					else break_flag = true;
				}
				if (break_flag == true) {
					count_ws = 0;
					break;
				}
			}
		}
		p << '\n';
		g.close();
	}
	else {
		if (g.is_open() == false) std::cout << "Не удалось открыть входной файл";
		if (p.is_open() == false) std::cout << "Не удалось открыть файл протокола";
	}
}

void PrintPoints(float A[n][2], unsigned i1, unsigned j1, unsigned i2, unsigned j2, std::fstream& p) {
	std::string points1 = "(" + ((A[i1][0] == int(A[i1][0])) ? std::to_string(int(A[i1][0])) : std::to_string(int(A[i1][0])) + '.' + std::to_string(A[i1][0] - int(A[i1][0])).substr((std::to_string(A[i1][0])[0] == '-' ? 3 : 2), 2)) + ", " + ((A[i1][1] == int(A[i1][1])) ? std::to_string(int(A[i1][1])) : std::to_string(int(A[i1][1])) + '.' + std::to_string(A[i1][1] - int(A[i1][1])).substr((std::to_string(A[i1][1])[0] == '-' ? 3 : 2), 2)) + "), (" + ((A[j1][0] == int(A[j1][0])) ? std::to_string(int(A[j1][0])) : std::to_string(int(A[j1][0])) + '.' + std::to_string(A[j1][0] - int(A[j1][0])).substr((std::to_string(A[j1][0])[0] == '-' ? 3 : 2), 2)) + ", " + ((A[j1][1] == int(A[j1][1])) ? std::to_string(int(A[j1][1])) : std::to_string(int(A[j1][1])) + '.' + std::to_string(A[j1][1] - int(A[j1][1])).substr((std::to_string(A[j1][1])[0] == '-' ? 3 : 2), 2)) + ")";
	std::string points2 = "(" + ((A[i2][0] == int(A[i2][0])) ? std::to_string(int(A[i2][0])) : std::to_string(int(A[i2][0])) + '.' + std::to_string(A[i2][0] - int(A[i2][0])).substr((std::to_string(A[i2][0])[0] == '-' ? 3 : 2), 2)) + ", " + ((A[i2][1] == int(A[i2][1])) ? std::to_string(int(A[i2][1])) : std::to_string(int(A[i2][1])) + '.' + std::to_string(A[i2][1] - int(A[i2][1])).substr((std::to_string(A[i2][1])[0] == '-' ? 3 : 2), 2)) + "), (" + ((A[j2][0] == int(A[j2][0])) ? std::to_string(int(A[j2][0])) : std::to_string(int(A[j2][0])) + '.' + std::to_string(A[j2][0] - int(A[j2][0])).substr((std::to_string(A[j2][0])[0] == '-' ? 3 : 2), 2)) + ", " + ((A[j2][1] == int(A[j2][1])) ? std::to_string(int(A[j2][1])) : std::to_string(int(A[j2][1])) + '.' + std::to_string(A[j2][1] - int(A[j2][1])).substr((std::to_string(A[j2][1])[0] == '-' ? 3 : 2), 2)) + ")";
	p << points1 << std::setw(55 - points1.size()) << ' ' << points2 << '\n' << '\n';
}

bool PointsMemor(float A[n][2], unsigned i1, unsigned j1, unsigned i2, unsigned j2, std::string B[10000], unsigned& k) {
	std::string tmp1 = "((" + std::to_string(A[i1][0]) + ", " + std::to_string(A[i1][1]) + "), (" + std::to_string(A[j1][0]) + ", " + std::to_string(A[j1][1]) + "); (" + std::to_string(A[i2][0]) + ", " + std::to_string(A[i2][1]) + "), (" + std::to_string(A[j2][0]) + ", " + std::to_string(A[j2][1]) + "))";
	std::string tmp2 = "((" + std::to_string(A[i2][0]) + ", " + std::to_string(A[i2][1]) + "), (" + std::to_string(A[j2][0]) + ", " + std::to_string(A[j2][1]) + "); (" + std::to_string(A[i1][0]) + ", " + std::to_string(A[i1][1]) + "), (" + std::to_string(A[j1][0]) + ", " + std::to_string(A[j1][1]) + "))";
	bool string_flag = false;
	for (unsigned i = 0; i < 10000; i++) {
		if (tmp1 == B[i] || tmp2 == B[i]) {
			string_flag = true;
			break;
		}
	}
	if (string_flag == true) return 0;
	else {
		B[k] = tmp1;
		k++;
		return 1;
	}
}

void Process(float A[n][2], unsigned a, std::fstream& p, std::fstream& e) {
	if (p.is_open() && e.is_open()) {
		float max_corn = 0;

		for (unsigned i1 = 0; i1 < a; i1++) {
			for (unsigned j1 = i1 + 1; j1 < a; j1++) {
				for (unsigned i2 = 0; i2 < a; i2++) {
					for (unsigned j2 = i2 + 1; j2 < a; j2++) {
						float k1, k2, b1, b2;
						Interpolation(A[i1][0], A[i1][1], A[j1][0], A[j1][1], k1, b1);
						Interpolation(A[i2][0], A[i2][1], A[j2][0], A[j2][1], k2, b2);
						float corn = abs((atan(k2) * (180 / pi) - atan(k1) * (180 / pi))) <= 90 ? abs((atan(k2) * (180 / pi) - atan(k1) * (180 / pi))) : 180 - abs((atan(k2) * (180 / pi) - atan(k1) * (180 / pi)));
						if (corn < 0) corn = 0;
						if (corn > max_corn) {
							max_corn = corn;
						}
					}
				}
			}
		}

		std::string points_memor[10000];
		unsigned k = 0;
		for (unsigned i1 = 0; i1 < a; i1++) {
			for (unsigned j1 = i1 + 1; j1 < a; j1++) {
				for (unsigned i2 = 0; i2 < a; i2++) {
					for (unsigned j2 = i2 + 1; j2 < a; j2++) {
						if (PointsMemor(A, i1, j1, i2, j2, points_memor, k)) {
							float k1, k2, b1, b2;
							Interpolation(A[i1][0], A[i1][1], A[j1][0], A[j1][1], k1, b1);
							Interpolation(A[i2][0], A[i2][1], A[j2][0], A[j2][1], k2, b2);
							float corn = abs((atan(k2) * (180 / pi) - atan(k1) * (180 / pi))) <= 90 ? abs((atan(k2) * (180 / pi) - atan(k1) * (180 / pi))) : 180 - abs((atan(k2) * (180 / pi) - atan(k1) * (180 / pi)));
							if (corn < 0) corn = 0;
							std::string s1, s2;
							if ((A[i1][0] - A[j1][0]) && (A[i2][0] - A[j2][0])) {
								s1 = "Первая прямая: " + std::to_string(int(k1)) + "." + std::to_string(k1 - int(k1)).substr((std::to_string(k1)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b1)[0] == '-') ? "-" : "+") + std::to_string(int(b1)).substr((std::to_string(b1)[0] == '-' && std::to_string(int(b1)) != "0") ? 1 : 0) + "." + std::to_string(b1 - int(b1)).substr((std::to_string(b1)[0] == '-' ? 3 : 2), 2) + "=0";
								s2 = "Вторая прямая: " + std::to_string(int(k2)) + "." + std::to_string(k2 - int(k2)).substr((std::to_string(k2)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b2)[0] == '-') ? "-" : "+") + std::to_string(int(b2)).substr((std::to_string(b2)[0] == '-' && std::to_string(int(b2)) != "0") ? 1 : 0) + "." + std::to_string(b2 - int(b2)).substr((std::to_string(b2)[0] == '-' ? 3 : 2), 2) + "=0";
								p << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
								PrintPoints(A, i1, j1, i2, j2, p);
							}
							else {
								if (A[i1][0] - A[j1][0] == 0 && A[i2][0] - A[j2][0] == 0) {
									s1 = "Первая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i1][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' && -1 * A[i1][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i1][0] - int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' ? 3 : 2), 2) + "=0";
									s2 = "Вторая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i2][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' && -1 * A[i2][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i2][0] - int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' ? 3 : 2), 2) + "=0";
									p << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
									PrintPoints(A, i1, j1, i2, j2, p);
								}
								else if (A[i1][0] - A[j1][0] == 0) {
									s1 = "Первая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i1][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' && -1 * A[i1][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i1][0] - int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' ? 3 : 2), 2) + "=0";
									s2 = "Вторая прямая: " + std::to_string(int(k2)) + "." + std::to_string(k2 - int(k2)).substr((std::to_string(k2)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b2)[0] == '-') ? "-" : "+") + std::to_string(int(b2)).substr((std::to_string(b2)[0] == '-' && std::to_string(int(b2)) != "0") ? 1 : 0) + "." + std::to_string(b2 - int(b2)).substr((std::to_string(b2)[0] == '-' ? 3 : 2), 2) + "=0";
									p << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
									PrintPoints(A, i1, j1, i2, j2, p);
								}
								else if (A[i2][0] - A[j2][0] == 0) {
									s1 = "Первая прямая: " + std::to_string(int(k1)) + "." + std::to_string(k1 - int(k1)).substr((std::to_string(k1)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b1)[0] == '-') ? "-" : "+") + std::to_string(int(b1)).substr((std::to_string(b1)[0] == '-' && std::to_string(int(b1)) != "0") ? 1 : 0) + "." + std::to_string(b1 - int(b1)).substr((std::to_string(b1)[0] == '-' ? 3 : 2), 2) + "=0";
									s2 = "Вторая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i2][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' && -1 * A[i2][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i2][0] - int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' ? 3 : 2), 2) + "=0";
									p << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
									PrintPoints(A, i1, j1, i2, j2, p);
								}
							}
							if (corn == max_corn) {
								if ((A[i1][0] - A[j1][0]) && (A[i2][0] - A[j2][0])) {
									s1 = "Первая прямая: " + std::to_string(int(k1)) + "." + std::to_string(k1 - int(k1)).substr((std::to_string(k1)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b1)[0] == '-') ? "-" : "+") + std::to_string(int(b1)).substr((std::to_string(b1)[0] == '-' && std::to_string(int(b1)) != "0") ? 1 : 0) + "." + std::to_string(b1 - int(b1)).substr((std::to_string(b1)[0] == '-' ? 3 : 2), 2) + "=0";
									s2 = "Вторая прямая: " + std::to_string(int(k2)) + "." + std::to_string(k2 - int(k2)).substr((std::to_string(k2)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b2)[0] == '-') ? "-" : "+") + std::to_string(int(b2)).substr((std::to_string(b2)[0] == '-' && std::to_string(int(b2)) != "0") ? 1 : 0) + "." + std::to_string(b2 - int(b2)).substr((std::to_string(b2)[0] == '-' ? 3 : 2), 2) + "=0";
									e << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << "Угол: " << corn << "\n";
									PrintPoints(A, i1, j1, i2, j2, e);
								}
								else {
									if (A[i1][0] - A[j1][0] == 0 && A[i2][0] - A[j2][0] == 0) {
										s1 = "Первая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i1][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' && -1 * A[i1][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i1][0] - int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' ? 3 : 2), 2) + "=0";
										s2 = "Вторая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i2][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' && -1 * A[i2][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i2][0] - int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' ? 3 : 2), 2) + "=0";
										e << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
										PrintPoints(A, i1, j1, i2, j2, e);
									}
									else if (A[i1][0] - A[j1][0] == 0) {
										s1 = "Первая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i1][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' && -1 * A[i1][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i1][0] - int(-1 * A[i1][0])).substr((std::to_string(-1 * A[i1][0])[0] == '-' ? 3 : 2), 2) + "=0";
										s2 = "Вторая прямая: " + std::to_string(int(k2)) + "." + std::to_string(k2 - int(k2)).substr((std::to_string(k2)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b2)[0] == '-') ? "-" : "+") + std::to_string(int(b2)).substr((std::to_string(b2)[0] == '-' && std::to_string(int(b2)) != "0") ? 1 : 0) + "." + std::to_string(b2 - int(b2)).substr((std::to_string(b2)[0] == '-' ? 3 : 2), 2) + "=0";
										e << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
										PrintPoints(A, i1, j1, i2, j2, e);
									}
									else if (A[i2][0] - A[j2][0] == 0) {
										s1 = "Первая прямая: " + std::to_string(int(k1)) + "." + std::to_string(k1 - int(k1)).substr((std::to_string(k1)[0] == '-' ? 3 : 2), 2) + "x-1.00y" + ((std::to_string(b1)[0] == '-') ? "-" : "+") + std::to_string(int(b1)).substr((std::to_string(b1)[0] == '-' && std::to_string(int(b1)) != "0") ? 1 : 0) + "." + std::to_string(b1 - int(b1)).substr((std::to_string(b1)[0] == '-' ? 3 : 2), 2) + "=0";
										s2 = "Вторая прямая: 1.00x+0.00y" + std::string(((std::to_string(-1 * A[i2][0])[0] == '-') ? "-" : "+")) + std::to_string(int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' && -1 * A[i2][0] != 0 ? 1 : 0)) + "." + std::to_string(-1 * A[i2][0] - int(-1 * A[i2][0])).substr((std::to_string(-1 * A[i2][0])[0] == '-' ? 3 : 2), 2) + "=0";
										e << s1 << std::setw(55 - s1.size()) << " " << s2 << std::setw(55 - s2.size()) << std::right << "Угол: " << corn << "\n";
										PrintPoints(A, i1, j1, i2, j2, e);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	else {
		if (e.is_open() == false) std::cout << "Не удалось открыть выходной файл";
		if (p.is_open() == false) std::cout << "Не удалось открыть файл протокола";
	}
}

int main()
{
	setlocale(LC_ALL, "Russian");
	std::fstream p; p.open("Protocol.txt", std::ios::out);
	std::fstream e; e.open("out.txt", std::ios::out);
	float A[n][2];
	unsigned a;
	SizeArr(a, p);
	InpArr(A, a, p);
	Process(A, a, p, e);
	p.close();
	e.close();
}

