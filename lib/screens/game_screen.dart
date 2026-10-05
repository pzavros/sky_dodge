import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/game_controller.dart';
import '../game/game_painter.dart';
import '../services/app_state.dart';
import '../widgets/game_hud.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final Ticker _ticker;
  late final Listenable _uiListenable;

  Duration? _lastTick;
  bool _actionBusy = false;
  int _lastShieldBreakCount = 0;
  int _lastDeathCount = 0;
  bool _lastSoundOn = true;
  Duration _lastPacePush = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = GameController(appState: widget.appState);
    _uiListenable = Listenable.merge(<Listenable>[
      _controller,
      widget.appState,
    ]);
    _lastSoundOn = widget.appState.soundOn;
    widget.appState.addListener(_onAppStateChanged);
    if (_lastSoundOn) {
      unawaited(widget.appState.audioService.startGameMusic());
      unawaited(
        widget.appState.audioService.setGamePace(_controller.speedProgress),
      );
    }
    _ticker = createTicker(_onFrame)..start();
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    unawaited(widget.appState.audioService.stopMusic());
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    if (_lastSoundOn == widget.appState.soundOn) return;
    _lastSoundOn = widget.appState.soundOn;

    if (_lastSoundOn) {
      unawaited(widget.appState.audioService.startGameMusic());
      unawaited(
        widget.appState.audioService.setGamePace(_controller.speedProgress),
      );
    } else {
      unawaited(widget.appState.audioService.stopMusic());
    }
  }

  void _onFrame(Duration elapsed) {
    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    }

    final dtMicros = (elapsed - _lastTick!).inMicroseconds;
    _lastTick = elapsed;

    final dt = dtMicros / Duration.microsecondsPerSecond;
    _controller.tick(dt);
    _dispatchAudioEvents();
    _dispatchMusicPace(elapsed);
  }

  void _dispatchAudioEvents() {
    if (_controller.shieldBreakCount > _lastShieldBreakCount) {
      _lastShieldBreakCount = _controller.shieldBreakCount;
      if (widget.appState.soundOn) {
        unawaited(widget.appState.audioService.playHit());
      }
    }

    if (_controller.deathCount > _lastDeathCount) {
      _lastDeathCount = _controller.deathCount;
      if (widget.appState.soundOn) {
        unawaited(widget.appState.audioService.stopMusic());
        unawaited(widget.appState.audioService.playLose());
      }
    }
  }

  void _dispatchMusicPace(Duration elapsed) {
    if (!widget.appState.soundOn || _controller.isGameOver) return;
    if (elapsed - _lastPacePush < const Duration(milliseconds: 280)) return;
    _lastPacePush = elapsed;

    unawaited(
      widget.appState.audioService.setGamePace(_controller.speedProgress),
    );
  }

  void _handleSwipe(DragEndDetails details) {
    if (_controller.isGameOver) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 160) return;

    if (velocity > 0) {
      _controller.moveLeft();
    } else {
      _controller.moveRight();
    }
  }

  void _handleTap(TapDownDetails details, double width) {
    if (_controller.isGameOver) return;
    final dx = details.localPosition.dx;
    if (dx < width * 0.46) {
      _controller.moveLeft();
    } else if (dx > width * 0.54) {
      _controller.moveRight();
    }
  }

  Future<void> _activateShield() async {
    final ok = await _controller.activateShield();
    if (ok || !mounted) return;
    _showSnack('No shield available right now.');
  }

  Future<void> _activateSlowMo() async {
    final ok = await _controller.activateSlowMo();
    if (ok || !mounted) return;
    _showSnack('No slow-mo available right now.');
  }

  Future<void> _reviveWithCoins() async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);

    final success = await _controller.reviveWithCoins();

    if (!success && mounted) {
      _showSnack('Not enough coins for revive.');
    } else if (success && widget.appState.soundOn) {
      unawaited(widget.appState.audioService.startGameMusic());
      unawaited(
        widget.appState.audioService.setGamePace(_controller.speedProgress),
      );
    }

    if (mounted) {
      setState(() => _actionBusy = false);
    }
  }

  Future<void> _reviveWithAd() async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);

    final success = await _controller.reviveWithAd();

    if (!success && mounted) {
      _showSnack('Rewarded ad unavailable right now.');
    } else if (success && widget.appState.soundOn) {
      unawaited(widget.appState.audioService.startGameMusic());
      unawaited(
        widget.appState.audioService.setGamePace(_controller.speedProgress),
      );
    }

    if (mounted) {
      setState(() => _actionBusy = false);
    }
  }

  Future<void> _retry() async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);

    await _controller.finalizeRunIfNeeded();
    await _controller.startNewRun();
    _lastTick = null;
    _lastShieldBreakCount = _controller.shieldBreakCount;
    _lastDeathCount = _controller.deathCount;
    if (widget.appState.soundOn) {
      unawaited(widget.appState.audioService.startGameMusic());
      unawaited(
        widget.appState.audioService.setGamePace(_controller.speedProgress),
      );
    }

    if (mounted) {
      setState(() => _actionBusy = false);
    }
  }

  Future<void> _goHome() async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);

    await _controller.finalizeRunIfNeeded();
    unawaited(widget.appState.audioService.stopMusic());

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final worldSize = Size(constraints.maxWidth, constraints.maxHeight);
          _controller.setWorldSize(worldSize);

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: _handleSwipe,
                  onTapDown: (details) =>
                      _handleTap(details, constraints.maxWidth),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: GamePainter(controller: _controller),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 10,
                left: 12,
                right: 12,
                child: AnimatedBuilder(
                  animation: _uiListenable,
                  builder: (context, _) {
                    return GameHud(
                      score: _controller.displayScore,
                      runCoins: _controller.runCoinsEarned,
                      shieldCount: widget.appState.shieldCount,
                      slowMoCount: widget.appState.slowMoCount,
                      shieldArmed: _controller.shieldArmed,
                      slowMoRemaining: _controller.slowMoRemaining,
                      onShield: _activateShield,
                      onSlowMo: _activateSlowMo,
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _uiListenable,
                  builder: (context, _) {
                    if (!_controller.isGameOver) {
                      return const SizedBox.shrink();
                    }

                    final best = max(
                      widget.appState.bestScore,
                      _controller.finalScore,
                    );

                    return GameOverScreen(
                      score: _controller.finalScore,
                      bestScore: best,
                      coinsEarned: _controller.coinsEarned,
                      coinsSpent: _controller.coinsSpentThisRun,
                      netCoins: _controller.netCoinsDelta,
                      currentCoins: widget.appState.coins,
                      balanceAfterClaim:
                          widget.appState.coins + _controller.coinsEarned,
                      canRevive: _controller.canRevive,
                      busy: _actionBusy,
                      onReviveCoins: _controller.canRevive
                          ? _reviveWithCoins
                          : null,
                      onReviveAd: _controller.canRevive ? _reviveWithAd : null,
                      onRetry: _retry,
                      onHome: _goHome,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
