import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_center.dart';

class DetailRow extends StatefulWidget {
  const DetailRow({Key? key}) : super(key: key);

  @override
  State<DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<DetailRow> {
  late DataCenter _dataCenter;
  late Map<String, dynamic> placeInfo;
  bool showPlaceInfo = false;

  @override
  void initState() {
    super.initState();
  }

  void retrievePlaceInfo() {
    placeInfo = {};
    _dataCenter.getPlaceInfo().then(
          (value) => setState(() {
            placeInfo = value;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    _dataCenter = context.watch<DataCenter>();

    if (showPlaceInfo == false &&
        !_dataCenter.curTag.startsWith('#') &&
        _dataCenter.curTag.toLowerCase() != "foodigram") {
      showPlaceInfo = true;
      retrievePlaceInfo();
    } else if (_dataCenter.curTag.startsWith('#') ||
        _dataCenter.curTag.toLowerCase() == "foodigram") {
      showPlaceInfo = false;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      color: const Color(0xb2e6e6e5),
      child: showPlaceInfo
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  // backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).primaryColor,
                  radius: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${_dataCenter.showedPostIndices.length}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Text("Posts",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            " ${placeInfo['address'] ?? "N/A"}",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            " ${placeInfo['number'] ?? "N/A"}",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ExpansionTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      Text(
                        " ${placeInfo['status'] ?? "N/A"}",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                  children: <Widget>[
                    placeInfo['openDays'] == null
                        ? Text(
                            "N/A",
                            style: Theme.of(context).textTheme.headline3,
                          )
                        : ListView.builder(
                            itemCount: placeInfo['openDays'].length,
                            itemBuilder: (BuildContext context, int index) {
                              return Text(
                                "${placeInfo['openDays'][index]}",
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center,
                              );
                            },
                            shrinkWrap: true,
                          ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  // backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).primaryColor,
                  radius: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${_dataCenter.showedPostIndices.length}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Text("Posts",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                CircleAvatar(
                  // backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).primaryColor,
                  radius: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${_dataCenter.numPlaces}",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Text("Places",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
