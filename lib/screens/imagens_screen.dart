import 'package:flutter/material.dart';

class ImagensScreen extends StatelessWidget {
  const ImagensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista das imagens
    final images = [
      {'path': 'assets/images/DK1.jpg', 'title': 'DK1'},
      {'path': 'assets/images/DK2.jpg', 'title': 'DK2'},
      {'path': 'assets/images/DK3.jpg', 'title': 'DK3'},
      {'path': 'assets/images/DK4.jpg', 'title': 'DK4'},
      {'path': 'assets/images/DK5.jpg', 'title': 'DK5'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagens Extras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galeria de Imagens',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return _buildImageCard(
                    context,
                    images[index]['path']!,
                    images[index]['title']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, String imagePath, String title) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Abrir imagem em tela cheia
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImagemTelaCheia(
                imagePath: imagePath,
                title: title,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Se a imagem não carregar, mostra um ícone
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Imagem não encontrada',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela para visualizar imagem em tela cheia
class ImagemTelaCheia extends StatelessWidget {
  final String imagePath;
  final String title;

  const ImagemTelaCheia({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}