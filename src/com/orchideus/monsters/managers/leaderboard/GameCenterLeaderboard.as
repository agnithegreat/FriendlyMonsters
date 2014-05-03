/**
 * Created by agnither on 23.04.14.
 */
package com.orchideus.monsters.managers.leaderboard {
import com.sticksports.nativeExtensions.gameCenter.GameCenter;

public class GameCenterLeaderboard extends Leaderboard {

    public function GameCenterLeaderboard() {
        if (GameCenter.isSupported) {
            GameCenter.init();
            GameCenter.authenticateLocalPlayer();
        }
    }

    override public function reportScore(leaderboard: String, score: int):void {
        if (GameCenter.isSupported && GameCenter.isAuthenticated) {
            GameCenter.reportScore(leaderboard, score);
        }
    }

    override public function showLeaderboard(leaderboard: String):void {
        if (GameCenter.isSupported && GameCenter.isAuthenticated) {
            GameCenter.showStandardLeaderboard(leaderboard);
        }
    }
}
}
