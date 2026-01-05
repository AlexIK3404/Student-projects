#include <fstream>
#include <iomanip>

int main()
{
	const unsigned N = 100;
	float A[N], B[N]; int L;
	unsigned ind = 1;
	std::fstream f, g; f.open("in.txt", std::ios::in); g.open("out.txt", std::ios::out);
	g << "Задача: Для последовательности из n вещественных значений a_i создать новую последовательность,\n"
		<< "состоящую из различных элементов исходной последовательности и входящих в нее в исходном порядке следования.\n"
		<< "Автор: Коняев Александр Евгеньевич; Группа: 2302; Версия 4.1\n"
		<< "Дата начала: 26.10.2022; Дата окончания:\n\n";
	if (f.is_open() == false) g << "Err open_in";
	else {
		f >> L; if (f.eof()) g << "Eof";
		else {
			if (0 > L) L = 0;
			else if (L > N) L = N;
			unsigned i = 0; while (1) {
				f >> A[i];
				if (f.eof()) { L = i+1; break; }
				else { i++; if (i >= L) break; }
			}
		}
	}
		f.close();
		g << L << std::endl; for (unsigned i = 0; i < L; i++) g << A[i] << std::endl; g << std::endl;
		if (L > 0) B[0] = A[0];
		int basic_L = L;
		for (unsigned i = 1; i < basic_L; i++) {
			bool flag = false;
			for (unsigned l = 0; l != L - 1; ++l) {
				if (A[i] == B[l]) {
					flag = true;
					break;
				}
			}
			if (flag == false) {
				B[ind] = A[i];
				ind++;
				L++;
			}
			L--;
		}
		g << L << std::endl; for (unsigned i = 0; i < L; i++) g << B[i] << std::endl;
		g.close();
}


