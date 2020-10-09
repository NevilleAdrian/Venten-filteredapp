import 'package:flutter/material.dart';

class FutureHelper<T> extends StatelessWidget {
  final Future<T> task;
  final Future<void> Function() onRefresh;
  final Widget whenEmpty;
  final Widget Function(BuildContext context, T data) builder;
  final Function actionWhenData;

  FutureHelper(
      {this.task,
      this.whenEmpty,
      this.builder,
      this.actionWhenData,
      this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: task,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('data is in the home ${snapshot.data}');
          if (actionWhenData != null) {
            print('something');
            actionWhenData(snapshot.data);
          }
          return onRefresh != null
              ? RefreshIndicator(
                  onRefresh: onRefresh,
                  child: builder(context, snapshot.data),
                )
              : builder(context, snapshot.data);
        } else if (snapshot.hasError) {
          return Container(
            height: 300.0,
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Text(
                snapshot.error.toString(),
                style: TextStyle(
                  fontSize: 15.0,
                  color: Color(0xFF1D1E2C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        // By default, show a loading spinner.
        return Center(
          child: SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          ),
        );
      },
    );
  }
}

class NoItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No item yet...",
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
