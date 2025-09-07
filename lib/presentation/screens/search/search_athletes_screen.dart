import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';

class SearchAthletesScreen extends StatefulWidget {
  const SearchAthletesScreen({super.key});

  @override
  State<SearchAthletesScreen> createState() => _SearchAthletesScreenState();
}

class _SearchAthletesScreenState extends State<SearchAthletesScreen> {
  String _selectedRace = 'S8 2025 Beijing';
  String _selectedDivision = 'All';
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _bibController = TextEditingController();
  
  final List<String> _races = ['S8 2025 Beijing', 'S7 2025 Shanghai'];
  final List<String> _divisions = ['All', 'Pro', 'Open', 'Doubles'];
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _bibController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Athletes'),
        leading: IconButton(
          onPressed: () => AppRouter.goBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // Search Form (max 30% screen height)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                // Race dropdown
                _buildDropdown(
                  context, 
                  'Race', 
                  _races, 
                  _selectedRace,
                  (value) => setState(() => _selectedRace = value!),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                
                // Division dropdown
                _buildDropdown(
                  context, 
                  'Division', 
                  _divisions,
                  _selectedDivision,
                  (value) => setState(() => _selectedDivision = value!),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                
                // Name and bib number fields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Enter first name',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: TextField(
                        controller: _bibController,
                        decoration: const InputDecoration(
                          labelText: 'Bib Number',
                          hintText: 'Enter bib',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                
                // Search button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _performSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Athletes'),
                  ),
                ),
              ],
            ),
          ),
          
          // Results section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Text(
                    'Search Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            'Enter search criteria above',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Search by name, bib number, or filter by race/division',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final searchCriteria = {
      'race': _selectedRace,
      'division': _selectedDivision,
      'firstName': _firstNameController.text.trim(),
      'bibNumber': _bibController.text.trim(),
    };
    
    // TODO: Implement actual search logic with database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching with: ${searchCriteria.toString()}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Widget _buildDropdown(
    BuildContext context, 
    String label, 
    List<String> options,
    String selectedValue,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: onChanged,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}