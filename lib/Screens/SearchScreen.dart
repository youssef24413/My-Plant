import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, String>> _plants = [];
  List<Map<String, String>> _filteredPlants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      setState(() => _isLoading = true);
      final csvString = await rootBundle.loadString('assets/data/final_dataset_with_images.csv');
      final csvData = CsvToListConverter().convert(csvString);

      if (csvData.isEmpty) throw Exception("CSV file is empty.");

      final headers = csvData[0].map((header) => header.toString()).toList();
      final plants = csvData.skip(1).map((row) {
        return {
          'name': headers.contains('name') ? row[headers.indexOf('name')]?.toString().trim() ?? 'Unknown' : 'Unknown',
          'image': headers.contains('Image Path') ? row[headers.indexOf('Image Path')]?.toString().trim() ?? 'assets/images/placeholder.png' : 'assets/images/placeholder.png',
          'temperature': headers.contains('temperature') ? row[headers.indexOf('temperature')]?.toString().trim() ?? 'N/A' : 'N/A',
          'brightness': headers.contains('brightness') ? row[headers.indexOf('brightness')]?.toString().trim() ?? 'N/A' : 'N/A',
          'solHumidity': headers.contains('solHumidity') ? row[headers.indexOf('solHumidity')]?.toString().trim() ?? 'N/A' : 'N/A',
          'suggestedSoilMix': headers.contains('suggestedSoilMix') ? row[headers.indexOf('suggestedSoilMix')]?.toString().trim() ?? 'N/A' : 'N/A',
          'generalCare': headers.contains('General care') ? row[headers.indexOf('General care')]?.toString().trim() ?? 'N/A' : 'N/A',
          'flower': headers.contains('Flower') ? row[headers.indexOf('Flower')]?.toString().trim() ?? 'No' : 'No',
          'watering': headers.contains('watering') ? row[headers.indexOf('watering')]?.toString().trim() ?? 'N/A' : 'N/A',
        };
      }).toList();

      setState(() {
        _plants = plants;
        _filteredPlants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading plants: $e")),
      );
    }
  }


  void _filterPlants(String query) {
    final filtered = _plants.where((plant) {
      final plantName = plant['name']!.toLowerCase();
      final lowerQuery = query.toLowerCase().trim();
      return plantName.contains(lowerQuery);
    }).toList();

    setState(() {
      _filteredPlants = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Plant Finder')),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Untitled3 1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _filterPlants,
                  decoration: InputDecoration(
                    hintText: "Search plants...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _filteredPlants.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_florist, size: 60, color: Colors.pink),
                      SizedBox(height: 10),
                      Text(
                        "No plants found.",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _filteredPlants.length,
                  itemBuilder: (context, index) {
                    final plant = _filteredPlants[index];
                    return _buildPlantCard(plant);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Map<String, String> plant) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            child: plant['image']!.isNotEmpty
                ? Image.asset(
              plant['image']!,
              height: 150,
              fit: BoxFit.cover,
            )
                : _buildImagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              plant['name'] ?? 'Unknown Plant',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 30, color: Colors.brown),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailScreen(plant: plant),
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.add, size: 30, color: Colors.brown),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${plant['name']} added to favorites!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }
}

class PlantDetailScreen extends StatelessWidget {
  final Map<String, String> plant;

  const PlantDetailScreen({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Untitled3 1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    plant['name']!,
                    style: TextStyle(color: Colors.black),
                  ),
                  centerTitle: true,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Image.asset(
                            plant['image']!,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 20),
                          InfoCard(title: "Temperature", icon: "🌡️", details: plant['temperature']!),
                          InfoCard(title: "Brightness", icon: "🌞", details: plant['brightness']!),
                          InfoCard(title: "Soil Humidity", icon: "💧", details: plant['solHumidity']!),
                          InfoCard(title: "Suggested Soil Mix", icon: "🪴", details: plant['suggestedSoilMix']!),
                          InfoCard(title: "General Care", icon: "🌱", details: plant['generalCare']!),
                          InfoCard(title: "Flower", icon: "🌸", details: plant['flower']!),
                          InfoCard(
                            title: "Watering",
                            icon: "💧",
                            details: "${plant['watering']} times a week",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String icon;
  final String details;

  InfoCard({required this.title, required this.icon, required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(details, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
