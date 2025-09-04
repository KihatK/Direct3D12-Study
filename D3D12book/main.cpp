#include <iostream>
#include "BoxApp.h"
#include "ShapesApp.h"
#include "LitWavesApp.h"
#include "LitColumnsApp.h"

using namespace std;

int main(int argc, char* argv[]) {
#if defined(DEBUG) || defined(_DEBUG)
	_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif
	try {
		std::unique_ptr<D3DApp> theApp;
		switch (atoi(argv[1])) {
		case 0:
			theApp = std::make_unique<BoxApp>();
			break;
		case 1:
			theApp = std::make_unique<ShapesApp>();
			break;
		case 2:
			theApp = std::make_unique<LitWavesApp>();
			break;
		case 3:
			theApp = std::make_unique<LitColumnsApp>();
			break;
		default:
			cout << argv[1] << " is not a valid example number" << endl;
			return 0;
		}
		if (!theApp->Initialize()) {
			return 0;
		}

		return theApp->Run();
	}
	catch (DxException& e) {
		cout << "HR Failed" << endl;
		MessageBox(nullptr, e.ToString().c_str(), L"HR Failed", MB_OK);
		return 0;
	}
}