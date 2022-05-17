import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart';
import '../data_center.dart';
import '../theme.dart';

class PlacesQuery extends StatefulWidget {
  final Map<String, String?> placeInfoText;
  final Function(Map<String, String?> selectedPlace) valueCallback;
  const PlacesQuery(
      {Key? key, required this.placeInfoText, required this.valueCallback})
      : super(key: key);

  @override
  State<PlacesQuery> createState() => _PlacesQueryState();
}

class _PlacesQueryState extends State<PlacesQuery> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  late GooglePlace _googlePlace;
  bool _isEnableTile = true;
  late Map<String, String?> placeInfoText = widget.placeInfoText;

  @override
  void initState() {
    _googlePlace = DataCenter().googlePlace;
    super.initState();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<List<Map<String, String?>>> _searchFoodiePlace() async {
    List<Map<String, String?>> result = [];
    List<String> types = ['restaurant', 'cafe', 'bar'];

    final bool isAccessed = await _handlePermission();
    if (!isAccessed) {
      return result;
    }
    Position position = await _geolocatorPlatform.getCurrentPosition();
    for (String type in types) {
      final places = await _googlePlace.search.getNearBySearch(
          Location(lat: position.latitude, lng: position.longitude), 1500,
          type: type);
      if (places != null) {
        places.results?.forEach((place) {
          final Map<String, String?> placeInfo = {};
          placeInfo["placeId"] = place.placeId;
          placeInfo["name"] = place.name;
          placeInfo["vicinity"] = place.vicinity;
          placeInfo["icon"] = place.icon;
          result.add(placeInfo);
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.place),
      title: Text(
        placeInfoText['name'] ?? "Find place",
        style: Theme.of(context).textTheme.headline3,
      ),
      subtitle: placeInfoText['vicinity'] != null
          ? Text(
              placeInfoText['vicinity']!,
              style: Theme.of(context).textTheme.headline3,
            )
          : null,
      iconColor: Theme.of(context).primaryColor,
      enabled: _isEnableTile,
      onTap: () async {
        setState(() {
          _isEnableTile = false;
        });
        List<Map<String, String?>> places = await _searchFoodiePlace();
        Map<String, String?>? selectedPlace = await showSearch(
          context: context,
          delegate:
              _SearchPlaces(nearPlaces: places, googlePlace: _googlePlace),
        );
        if (selectedPlace != null) {
          setState(() {
            placeInfoText = selectedPlace;
            widget.valueCallback(placeInfoText);
            _isEnableTile = true;
          });
        } else {
          setState(() {
            _isEnableTile = true;
          });
        }
      },
    );
  }
}

class _SearchPlaces extends SearchDelegate<Map<String, String?>> {
  final List<Map<String, String?>> nearPlaces;
  final GooglePlace googlePlace;
  _SearchPlaces({required this.nearPlaces, required this.googlePlace});

  Future<List<Map<String, String?>>> _findPlacesByText(String inquery) async {
    // Dummy query at the top
    final List<Map<String, String?>> result = [
      {'name': query, 'placeId': null, 'vicinity': null}
    ];
    // Suggestion matching query
    result.addAll(nearPlaces
        .where((place) =>
            place['name']!.toLowerCase().contains(inquery.toLowerCase()))
        .toList());
    // Text query
    List<String> types = ['restaurant', 'cafe', 'bar'];
    for (String type in types) {
      final places =
          await googlePlace.search.getTextSearch(inquery, type: type);
      places!.results?.forEach((place) {
        final Map<String, String?> placeInfo = {};
        placeInfo["placeId"] = place.placeId;
        placeInfo["name"] = place.name ?? inquery;
        placeInfo["vicinity"] = place.formattedAddress;
        placeInfo["icon"] = place.icon;
        result.add(placeInfo);
      });
    }

    return result;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return customTheme();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          query = "";
          close(context, {});
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: _findPlacesByText(query),
        builder: (context, AsyncSnapshot<List<Map<String, String?>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  query = snapshot.data![index]['name']!;
                  close(context, snapshot.data![index]);
                },
                leading: snapshot.data![index]['icon'] != null
                    ? ImageIcon(NetworkImage(snapshot.data![index]['icon']!))
                    : const Icon(Icons.place_outlined),
                title: Text(
                  snapshot.data![index]['name']!,
                  style: Theme.of(context).textTheme.headline3,
                ),
                subtitle: snapshot.data![index]['vicinity'] != null
                    ? Text(
                        snapshot.data![index]['vicinity']!,
                        style: Theme.of(context).textTheme.headline3,
                      )
                    : const SizedBox(),
                iconColor: Theme.of(context).primaryColor,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestedPlaces = nearPlaces
        .where((place) =>
            place['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestedPlaces.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = suggestedPlaces[index]['name']!;
          close(context, suggestedPlaces[index]);
        },
        leading: ImageIcon(NetworkImage(suggestedPlaces[index]['icon']!)),
        title: Text(
          suggestedPlaces[index]['name']!,
          style: Theme.of(context).textTheme.headline3,
        ),
        subtitle: Text(
          suggestedPlaces[index]['vicinity']!,
          style: Theme.of(context).textTheme.headline3,
        ),
        iconColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
