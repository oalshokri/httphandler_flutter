import 'package:flutter/material.dart';
import 'package:httphandler/features/profile/links/providers/links_provider.dart';
import 'package:provider/provider.dart';

import '../../core/util/api_response.dart';

class ProfileView extends StatefulWidget {
  static const id = '/profileView';

  final bool Function(UserScrollNotification)? onNotification;

  const ProfileView({super.key, this.onNotification});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LinkProvider>(
      builder: (_, linkProvider, __) {
        if (linkProvider.linkList.status == Status.LOADING) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (linkProvider.linkList.status == Status.ERROR) {
          return Center(
            child: Text('${linkProvider.linkList.message}'),
          );
        }
        return Center(
          child: ListView.builder(
            itemCount: linkProvider.linkList.data?.length,
            itemBuilder: (context, index) {
              return Text('');
            },
          ),
        );
      },
    );
  }
}
