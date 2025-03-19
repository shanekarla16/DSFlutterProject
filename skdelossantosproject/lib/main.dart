import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SK Delos Santos Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.lightBlue.shade100,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final Color _backgroundColor = Colors.lightBlue.shade100;
  final player = AudioPlayer();
  final List<String> songList = [
    'yellow.mp3',
    'NightChanges.mp3',
    'EmptySeats.mp3',
    'DieWithSmile.mp3',
    'Upuan.mp3'
  ];
  String currentSong = '';
  bool isPlaying = false;

  // Todo list items
  final List<String> todoItems = [];
  final TextEditingController taskController = TextEditingController();

  // Background color choices
  final List<Color> backgroundColors = [
    Colors.lightBlue.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.amber.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];
  int selectedColorIndex = 0;

  @override
  void dispose() {
    player.dispose();
    taskController.dispose();
    super.dispose();
  }

  void playAudio(String assetPath) async {
    if (isPlaying) {
      await player.stop();
    }
    
    await player.play(AssetSource(assetPath));
    setState(() {
      isPlaying = true;
      currentSong = assetPath;
    });
  }

  void pauseAudio() async {
    if (isPlaying) {
      await player.pause();
      setState(() {
        isPlaying = false;
      });
    } else if (currentSong.isNotEmpty) {
      await player.resume();
      setState(() {
        isPlaying = true;
      });
    }
  }

  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        todoItems.add(taskController.text);
        taskController.clear();
      });
    }
  }

  void changeBackgroundColor(int index) {
    setState(() {
      selectedColorIndex = index;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Background color changed!'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens
    final List<Widget> _screens = [
      _buildTodoScreen(),
      _buildColorScreen(),
      _buildAudioScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColors[selectedColorIndex],
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'To Do List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.color_lens),
            label: 'Background Color',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Audio Player',
          ),
        ],
      ),
    );
  }

  Widget _buildTodoScreen() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Your Tasks',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new task...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: addTask,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: todoItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No tasks yet!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add your first task above',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: todoItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(todoItems[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                todoItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorScreen() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Background Color',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: backgroundColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => changeBackgroundColor(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColors[index],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selectedColorIndex == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: selectedColorIndex == index
                        ? const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 40,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioScreen() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Audio Player',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: songList.length,
              itemBuilder: (context, index) {
                final song = songList[index];
                final isSelected = song == currentSong;
                final songName = song.replaceAll('.mp3', '');
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected && isPlaying ? Icons.pause : Icons.play_arrow,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                    title: Text(
                      songName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      if (isSelected && isPlaying) {
                        pauseAudio();
                      } else {
                        playAudio(song);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          if (currentSong.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    currentSong.replaceAll('.mp3', ''),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 40,
                        onPressed: () {
                          int currentIndex = songList.indexOf(currentSong);
                          if (currentIndex > 0) {
                            playAudio(songList[currentIndex - 1]);
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: pauseAudio,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 40,
                        onPressed: () {
                          int currentIndex = songList.indexOf(currentSong);
                          if (currentIndex < songList.length - 1) {
                            playAudio(songList[currentIndex + 1]);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}