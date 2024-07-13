import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/blocs/map_bloc/map_bloc.dart';

class ToggleMapStyleButton extends StatelessWidget {
  const ToggleMapStyleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 140,
      right: 10,
      child: FloatingActionButton(
        heroTag: 'toggleMapStyleButton',
        backgroundColor: Colors.white,
        onPressed: () {
          context.read<MapBloc>().add(ToggleMapStyle());
        },
        mini: true,
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoaded) {
              return Icon(
                state.isBlackStyle ? Icons.brightness_3 : Icons.brightness_5,
                color: Theme.of(context).colorScheme.onPrimary,
              );
            } else {
              return const Icon(Icons.brightness_3);
            }
          },
        ),
      ),
    );
  }
}
