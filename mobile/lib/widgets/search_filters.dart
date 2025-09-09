import 'package:flutter/material.dart';
import '../design_tokens.dart';

class SearchFilters extends StatelessWidget {
  final TextEditingController controller;
  final List<String> filters;
  final String selectedFilter;
  final void Function(String) onFilterSelected;
  final void Function(String) onSearchChanged;

  const SearchFilters({
    super.key,
    required this.controller,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9AA5AD)),
            hintText: 'Search shops, city, category',
            hintStyle: AppTypography.body.copyWith(color: Color(0xFF9AA5AD)),
            filled: true,
            fillColor: const Color(0xFF12171C),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
          ),
          style: AppTypography.body.copyWith(color: Color(0xFFE6EEF3)),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final bool selected = filter == selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter,
                        style: AppTypography.body.copyWith(
                          color: selected
                              ? Color(0xFFE6EEF3)
                              : Color(0xFFB7C2C8),
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (selected)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.check,
                            color: Color(0xFF0F9D58),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) => onFilterSelected(filter),
                  selectedColor: const Color(0xFF0F9D58),
                  backgroundColor: const Color(0xFF232A31),
                  labelStyle: AppTypography.body,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
