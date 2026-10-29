import 'package:flutter/material.dart';

class CitySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onMyLocation;
  final bool busy;

  const CitySearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onMyLocation,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Որոնել քաղաք...',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  IconButton(
                    tooltip: 'Որոնել',
                    onPressed: onSearch,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 9),
        Material(
          color: Colors.white.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: 'Իմ տեղը',
            onPressed: onMyLocation,
            icon: const Icon(
              Icons.my_location_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
