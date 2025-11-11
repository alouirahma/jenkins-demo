// lib/Screens/events_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile2025/Services/event_service.dart';
import 'package:mobile2025/Entites/event.dart';
import 'package:mobile2025/Screens/event_detail_screen.dart';
import 'package:mobile2025/Screens/add_event_screen.dart';
import 'package:mobile2025/Widgets/live_badge.dart';
import 'package:mobile2025/Widgets/video_thumbnail.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;

  // FILTRE PAR TAGS
  final List<String> filterTags = ['Concert', 'Live', 'Gratuit', 'Premium', 'DJ', 'Pop', 'Rock'];
  String? selectedFilter;

  // MODE RECOMMANDATIONS
  bool _showRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final List<Event> data;
      if (_showRecommendations) {
        data = await _eventService.getRecommendedEvents('u1'); // Utilisateur connecté
      } else {
        data = await _eventService.getUpcomingEvents();
      }

      if (!mounted) return;

      setState(() {
        _allEvents = data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Erreur: $error');
    }
  }

  void _applyFilter() {
    setState(() {
      if (selectedFilter == null) {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents = _allEvents.where((event) {
          return (event.tags ?? []).contains(selectedFilter!);
        }).toList();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEventScreen()),
    );
    if (result == true && mounted) {
      await _loadEvents();
    }
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showRecommendations ? 'Recommandés pour toi' : 'Événements à venir'),
        actions: [
          // Bouton Recommandations / Tous
          IconButton(
            icon: Icon(_showRecommendations ? Icons.recommend : Icons.event),
            onPressed: () {
              setState(() {
                _showRecommendations = !_showRecommendations;
                selectedFilter = null; // Reset filtre
              });
              _loadEvents();
            },
            tooltip: _showRecommendations ? 'Voir tous' : 'Recommandations',
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: _navigateToAddEvent),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      body: Column(
        children: [
          // FILTRE PAR TAGS
          if (!_showRecommendations)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterTags.map((String tag) {
                    final bool isSelected = selectedFilter == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: Colors.blue.withValues(alpha: 0.2),
                        checkmarkColor: Colors.blue,
                        labelStyle: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.grey[700],
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            selectedFilter = selected ? tag : null;
                          });
                          _applyFilter();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // LISTE DES ÉVÉNEMENTS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _showRecommendations
                                  ? 'Aucune recommandation pour le moment'
                                  : selectedFilter == null
                                      ? 'Aucun événement à venir'
                                      : 'Aucun événement "$selectedFilter"',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            if (selectedFilter != null)
                              TextButton(
                                onPressed: () {
                                  setState(() => selectedFilter = null);
                                  _applyFilter();
                                },
                                child: const Text('Effacer le filtre'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return _buildEventCard(event);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    const String userId = 'u1';

    return GestureDetector(
      onHorizontalDragEnd: (details) async {
        if (details.velocity.pixelsPerSecond.dx > 500) {
          try {
            await _eventService.registerToEvent(event.id, userId);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inscrit !'), backgroundColor: Colors.green),
            );
            _loadEvents();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
            );
          }
        } else if (details.velocity.pixelsPerSecond.dx < -500) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ignoré: ${event.title}'), backgroundColor: Colors.orange),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: VideoThumbnail(
            videoUrl: event.videoUrl,
            fallbackImage: event.image,
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (event.isLiveNow()) const LiveBadge(),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text('${event.date} ${event.time ?? ''}', style: const TextStyle(fontSize: 14)),
              if (event.location != null)
                Text(event.location!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                '${event.registeredUsers.length} participant${event.registeredUsers.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: Colors.blue),
              ),
              // TAGS DANS LA CARTE
              if (event.tags != null && event.tags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    children: event.tags!.take(3).map((String tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () => _navigateToEventDetail(event),
        ),
      ),
    );
  }
}