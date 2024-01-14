import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String readRepositories = """
  query ReadRepositories(\$nRepositories: Int!) {
    viewer {
      repositories(last: \$nRepositories) {
        nodes {
          id
          name
          viewerHasStarred
        }
      }
    }
  }
""";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Query(
        options: QueryOptions(
          document: gql(readRepositories),
          variables: const {
            'nRepositories': 50,
          },
          pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            print(result.exception.toString());
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Text('Loading');
          }

          // it can be either Map or List
          List? feedList = result.data?['viewer']?['repositories']?['nodes'];
          if (feedList == null) {
            return const Text('No repositories');
          }

          return ListView.builder(
            itemCount: feedList.length,
            itemBuilder: (context, index) {
              final feedListItems = feedList[index];
              // List tagList = feedListItems['name'];
              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(feedListItems['name'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
