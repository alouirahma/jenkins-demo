// lib/Screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile2025/Services/event_service.dart';
import 'package:mobile2025/Entites/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  late Event event;
  bool _isRegistered = false;
  bool _isLoading = false;
  final String _currentUserId = 'u1'; // À remplacer par l'ID utilisateur réel

  @override
  void initState() {
    super.initState();
    event = widget.event;
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    try {
      final isRegistered = await _eventService.isUserRegistered(event.id, _currentUserId);
      if (!mounted) return; // ✅ Vérification importante
      setState(() {
        _isRegistered = isRegistered;
      });
    } catch (error) {
      if (!mounted) return; // ✅
      _showError('Erreur de vérification: $error');
    }
  }

  Future<void> _toggleRegistration() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isRegistered) {
        await _eventService.unregisterFromEvent(event.id, _currentUserId);
      } else {
        await _eventService.registerToEvent(event.id, _currentUserId);
      }
      
      // ✅ Vérifier mounted avant d'utiliser setState ou context
      if (!mounted) return;
      
      setState(() {
        _isRegistered = !_isRegistered;
        _isLoading = false;
      });

      // Recharger les données de l'événement
      final updatedEvent = await _eventService.getEventById(event.id);
      if (!mounted) return; // ✅ Vérification avant mise à jour
      
      if (updatedEvent != null) {
        setState(() {
          event = updatedEvent;
        });
      }

      // ✅ Vérifier mounted avant d'utiliser ScaffoldMessenger
      if (!mounted) return;
      _showSuccessMessage(_isRegistered ? 'Inscription confirmée !' : 'Désinscription effectuée');
      
    } catch (error) {
      if (!mounted) return; // ✅
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur: $error');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'événement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Fonctionnalité de partage
              _shareEvent();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image de l'événement
                  if (event.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        event.image!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    )
                  else
                    _buildPlaceholderImage(),

                  const SizedBox(height: 20),

                  // Titre
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informations de base
                  _buildInfoRow(Icons.calendar_today, 'Date', '${event.date} ${event.time ?? ''}'),
                  if (event.location != null) _buildInfoRow(Icons.location_on, 'Lieu', event.location!),
                  if (event.link != null) _buildInfoRow(Icons.link, 'Lien', event.link!),

                  const SizedBox(height: 16),

                  // Description
                  if (event.description != null) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Participants
                  _buildParticipantsSection(),

                  const SizedBox(height: 20),

                  // Bouton d'inscription
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _toggleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRegistered ? Colors.orange : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isRegistered ? 'SE DÉSINSCRIRE' : "S'INSCRIRE",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.event, size: 64, color: Colors.blue),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participants',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${event.registeredUsers.length} personne(s) inscrite(s)',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  void _shareEvent() {
    // Implémentation du partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à implémenter'),
      ),
    );
  }
}