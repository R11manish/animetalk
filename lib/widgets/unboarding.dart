import 'package:AnimeTalk/constants/app_logo.dart';
import 'package:AnimeTalk/models/user_details.dart';
import 'package:flutter/material.dart';

class UserOnboardingDialog extends StatefulWidget {
  final Function(UserDetails) onSubmit;

  const UserOnboardingDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<UserOnboardingDialog> createState() => _UserOnboardingDialogState();
}

class _UserOnboardingDialogState extends State<UserOnboardingDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<UserDetails>(
      validator: (_) {
        if (_nameController.text.isEmpty) {
          return 'Please enter your name';
        }
        if (_emailController.text.isEmpty) {
          return 'Please enter your email';
        }
        if (!_isValidEmail(_emailController.text)) {
          return 'Please enter a valid email';
        }
        if (_selectedGender.isEmpty) {
          return 'Please select your gender';
        }
        if (_selectedDate == null) {
          return 'Please select your date of birth';
        }
        return null;
      },
      builder: (FormFieldState<UserDetails> state) {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(),
                const SizedBox(height: 16),
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help us personalize your experience',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => state.didChange(null),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => state.didChange(null),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Male',
                        isSelected: _selectedGender == 'Male',
                        onTap: () {
                          setState(() => _selectedGender = 'Male');
                          state.didChange(null);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GenderOption(
                        label: 'Female',
                        isSelected: _selectedGender == 'Female',
                        onTap: () {
                          setState(() => _selectedGender = 'Female');
                          state.didChange(null);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GenderOption(
                        label: 'Other',
                        isSelected: _selectedGender == 'Other',
                        onTap: () {
                          setState(() => _selectedGender = 'Other');
                          state.didChange(null);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? '-/-/-'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (state.validate()) {
                      final userDetails = UserDetails(
                          name: _nameController.text,
                          gender: _selectedGender.toLowerCase(),
                          dob: _selectedDate,
                          email: _emailController.text);
                      widget.onSubmit(userDetails);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('Get Started',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ));
      },
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
