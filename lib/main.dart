import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/minibonk_game.dart';
import 'models/weapon_definition.dart';
import 'ui/widgets/debug_overlay.dart';
import 'ui/widgets/game_over_overlay.dart';
import 'ui/widgets/hud_overlay.dart';
import 'ui/widgets/pause_overlay.dart';
import 'ui/widgets/upgrade_overlay.dart';
import 'ui/widgets/victory_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MinibonkApp());
}

class MinibonkApp extends StatelessWidget {
  const MinibonkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minibonk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryTextTheme: const TextTheme(),
        textTheme: const TextTheme(),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080B13),
        fontFamily: 'Galmuri9',
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _weaponSlots = 4;
  int _cardSlots = 4;
  WeaponDefinition _selectedWeapon = WeaponRegistry.allWeapons.first;
  bool _isPlaying = false;
  Key _gameKey = UniqueKey();

  void _startGame() {
    setState(() {
      _gameKey = UniqueKey();
      _isPlaying = true;
    });
  }

  void _restartGame() {
    setState(() {
      _gameKey = UniqueKey();
      _isPlaying = true;
    });
  }

  void _exitToMenu() {
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaying) {
      return Scaffold(
        body: GameWidget<MinibonkGame>.controlled(
          key: _gameKey,
          gameFactory: () => MinibonkGame(
            maxWeaponSlots: _weaponSlots,
            maxCardSlots: _cardSlots,
            initialWeapon: _selectedWeapon,
          ),
          overlayBuilderMap: {
            'hud': (context, game) => HudOverlay(game: game),
            'upgrade': (context, game) => UpgradeOverlay(game: game),
            'pause': (context, game) => PauseOverlay(
              game: game,
              onRestart: _restartGame,
              onExit: _exitToMenu,
            ),
            'debug': (context, game) => DebugOverlay(game: game),
            'game_over': (context, game) => GameOverOverlay(
              game: game,
              onRestart: _restartGame,
              onExit: _exitToMenu,
            ),
            'victory': (context, game) => VictoryOverlay(
              game: game,
              onRestart: _restartGame,
              onExit: _exitToMenu,
            ),
          },
          initialActiveOverlays: const ['hud'],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF101726), Color(0xFF060910)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title Logo (Sharp High-Tech Neon Emblem)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF00E5FF),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF00E5FF,
                            ).withValues(alpha: 0.35),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_moon_outlined,
                        size: 48,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MINIBONK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        shadows: [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '2.5D 탑다운 로그라이크 전장 개척 서바이벌',
                      style: TextStyle(
                        color: Color(0xFF90A4AE),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Configuration Box (Sharp Bevel Look)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B101D).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 12,
                                color: const Color(0xFF00E5FF),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '런 커스텀 설정 // RUN CONFIGURATION',
                                style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF182236), height: 22),

                          // Starting Weapon Selection
                          const Text(
                            '시작 무기 선택',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: WeaponRegistry.allWeapons.take(4).map((
                              w,
                            ) {
                              final isSelected = _selectedWeapon.id == w.id;
                              return ChoiceChip(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF263238),
                                    width: 1.0,
                                  ),
                                ),
                                label: Text(w.nameKo),
                                selected: isSelected,
                                selectedColor: const Color(0xFF00E5FF),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF060910)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedWeapon = w);
                                  }
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 18),

                          // Weapon Slot Count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '무기 슬롯 개수',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [1, 2, 3, 4].map((slots) {
                                  final isSelected = _weaponSlots == slots;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        side: BorderSide(
                                          color: isSelected
                                              ? const Color(0xFF00E5FF)
                                              : const Color(0xFF263238),
                                          width: 1.0,
                                        ),
                                      ),
                                      label: Text('$slots'),
                                      selected: isSelected,
                                      selectedColor: const Color(0xFF00E5FF),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF060910)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _weaponSlots = slots);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Card Slot Count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '카드/아이템 슬롯 개수',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [1, 2, 3, 4].map((slots) {
                                  final isSelected = _cardSlots == slots;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        side: BorderSide(
                                          color: isSelected
                                              ? const Color(0xFFFFB300)
                                              : const Color(0xFF263238),
                                          width: 1.0,
                                        ),
                                      ),
                                      label: Text('$slots'),
                                      selected: isSelected,
                                      selectedColor: const Color(0xFFFFB300),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF060910)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _cardSlots = slots);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Game Start Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: const Color(0xFF060910),
                          elevation: 0,
                          shadowColor: const Color(
                            0xFF00E5FF,
                          ).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: _startGame,
                        child: const Text(
                          '전장 진입 (Game Start)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      '조작: 이동 (WASD / 방향키 / 가상 조이스틱) • 대시 (스페이스바 / DASH 버튼) • 일시정지 (ESC) • 디버그 (F1)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF546E7A), fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
