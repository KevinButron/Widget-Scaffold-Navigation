import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Drawer + BottomBar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 46, 200, 228),
        ),
      ),
      home: const MyHomePage(title: 'Navigation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedBottomIndex = 0;
  bool _showHome = true;

  List<dynamic> _motocicletas = [];

  void _incrementCounter() {
    setState(() {
      if (_counter < 20) {
        _counter++;
        if (_counter == 20) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Valor máximo alcanzado (20)'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _decrementCounter() {
    if (_counter == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se permiten números negativos'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _counter--;
      });
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contador reiniciado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectHome() {
    Navigator.of(context).pop();
    setState(() {
      _showHome = true;
    });
  }

  void _onBottomNavTapped(int index) async {
    if (_showHome || index != _selectedBottomIndex) {
      Navigator.of(context).maybePop();
      setState(() {
        _showHome = false;
        _selectedBottomIndex = index;
      });

      if (_motocicletas.isEmpty) {
        final String data =
            await rootBundle.loadString('assets/motocicletas.json');
        final List<dynamic> lista = json.decode(data);
        setState(() {
          _motocicletas = lista;
        });
      }
    }
  }

  Widget _buildContent() {
    if (_showHome) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kevin Nathanael Butron Sanchez',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(

                  heroTag: 'increment',
                  onPressed: _incrementCounter,
                  tooltip: 'Incrementar',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                 heroTag: 'decrement',
                  onPressed: _decrementCounter,
                  tooltip: 'Decrementar',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: _resetCounter,
                  tooltip: 'Reiniciar',
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.restart_alt),
                ),
              ],
            ),
          ),
        ],
      );
    }

    switch (_selectedBottomIndex) {
      case 0:
        return Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Lista de motocicletas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _motocicletas.length,
                itemBuilder: (context, index) {
                  final moto = _motocicletas[index];
                  return ListTile(
                    leading: const Icon(Icons.motorcycle),
                    title: Text('${moto['marca']} - ${moto['modelo']}'),
                    subtitle: Text('Año: ${moto['año']}'),
                  );
                },
              ),
            ),
          ],
        );
      case 1:
        if (_motocicletas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final moto = _motocicletas[0];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  moto['imagen'] != null
                      ? Image.network(
                          moto['imagen'],
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                        )
                      : const SizedBox(
                          height: 200,
                          child: Icon(Icons.image_not_supported, size: 100),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${moto['marca']} ${moto['modelo']}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Año: ${moto['año']}'),
                        Text('Color: ${moto['color'] ?? "Desconocido"}'),
                        Text('Cilindraje: ${moto['cilindraje'] ?? "Desconocido"}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 2:
        if (_motocicletas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _motocicletas.length,
            itemBuilder: (context, index) {
              final moto = _motocicletas[index];
              final imageUrl = moto['imagen'];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageDetailPage(motocicleta: moto),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        )
                      : const Center(child: Icon(Icons.image_not_supported)),
                ),
              );
            },
          ),
        );
      default:
        return const Center(child: Text("Vista desconocida"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 46, 200, 228),
              ),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: _selectHome,
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista'),
              onTap: () => _onBottomNavTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Tarjeta'),
              onTap: () => _onBottomNavTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Imagen'),
              onTap: () => _onBottomNavTapped(2),
            ),
          ],
        ),
      ),
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: const Color.fromARGB(255, 46, 200, 228),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Tarjeta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Imagen',
          ),
        ],
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final Map<String, dynamic> motocicleta;

  const ImageDetailPage({super.key, required this.motocicleta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${motocicleta['marca']} ${motocicleta['modelo']}'),
        backgroundColor: const Color.fromARGB(255, 46, 200, 228),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            motocicleta['imagen'] != null
                ? Image.network(
                    motocicleta['imagen'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  )
                : const SizedBox(
                    height: 250,
                    child: Icon(Icons.image_not_supported, size: 100),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${motocicleta['marca']} ${motocicleta['modelo']}',
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Año: ${motocicleta['año']}'),
                  Text('Color: ${motocicleta['color'] ?? "Desconocido"}'),
                  Text('Cilindraje: ${motocicleta['cilindraje'] ?? "Desconocido"}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(motocicleta['descripcion'] ?? 'Sin descripción disponible'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
