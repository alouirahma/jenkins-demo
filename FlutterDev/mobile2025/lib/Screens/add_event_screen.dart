// lib/Screens/add_event_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile2025/Services/event_service.dart';
import 'package:mobile2025/Entites/event.dart';
import 'package:uuid/uuid.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final EventService _eventService = EventService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  // MULTI-SELECT CHIPS
  final List<String> _selectedTags = [];
  final List<String> availableTags = [
    'Concert',
    'Live',
    'Gratuit',
    'Premium',
    'DJ',
    'Pop',
    'Rock',
    'Rap',
    'Electro'
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final newEvent = Event(
        id: const Uuid().v4(),
        title: _titleController.text,
        date: _dateController.text,
        time: _timeController.text.isNotEmpty ? _timeController.text : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        link: _linkController.text.isNotEmpty ? _linkController.text : null,
        image: _imageController.text.isNotEmpty ? _imageController.text : null,
        videoUrl: _videoController.text.isNotEmpty ? _videoController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
      );

      await _eventService.createEvent(newEvent);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      _dateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un événement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // TITRE
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // DATE
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (v) => v?.isEmpty ?? true ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // HEURE
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Heure (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: '20:00',
                ),
              ),
              const SizedBox(height: 16),

              // LIEU
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'En ligne ou adresse physique',
                ),
              ),
              const SizedBox(height: 16),

              // LIEN
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Lien (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),

              // IMAGE
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),

              // VIDÉO
              TextFormField(
                controller: _videoController,
                decoration: const InputDecoration(
                  labelText: 'URL Vidéo (optionnel)',
                  border: OutlineInputBorder(),
                  hintText: 'https://... (MP4 recommandé)',
                  prefixIcon: Icon(Icons.videocam),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // TAGS - MULTI-SELECT
              const Text('Tags (optionnel)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: Colors.blue.withValues(alpha: 0.2), // CORRIGÉ
                    checkmarkColor: Colors.blue,
                    onSelected: (selected) {
                      setState(() {
                        selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // BOUTON CRÉER
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'CRÉER L\'ÉVÉNEMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _linkController.dispose();
    _imageController.dispose();
    _videoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}