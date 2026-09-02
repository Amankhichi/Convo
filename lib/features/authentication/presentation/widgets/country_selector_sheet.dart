import 'package:convo/app/theme/app_colors.dart';
import 'package:convo/features/authentication/data/models/country_model.dart';
import 'package:flutter/material.dart';

class CountrySelectorSheet extends StatefulWidget {
  final Country selectedCountry;
  final ValueChanged<Country> onSelectCountry;

  const CountrySelectorSheet({
    super.key,
    required this.selectedCountry,
    required this.onSelectCountry,
  });

  @override
  State<CountrySelectorSheet> createState() => _CountrySelectorSheetState();
}

class _CountrySelectorSheetState extends State<CountrySelectorSheet> {
  final TextEditingController searchController = TextEditingController();
  List<Country> filteredCountries = Country.countries;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    final cleanQuery = query.toLowerCase().trim();
    setState(() {
      if (cleanQuery.isEmpty) {
        filteredCountries = Country.countries;
      } else {
        filteredCountries = Country.countries
            .where(
              (c) =>
                  c.name.toLowerCase().contains(cleanQuery) ||
                  c.dialCode.contains(cleanQuery) ||
                  c.code.toLowerCase().contains(cleanQuery),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Select Country",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: "Search country or dial code",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filteredCountries.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                final isSelected = country.dialCode == widget.selectedCountry.dialCode &&
                    country.code == widget.selectedCountry.code;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    country.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : Colors.grey.shade700,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      ],
                    ],
                  ),
                  onTap: () {
                    widget.onSelectCountry(country);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
