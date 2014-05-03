/**
 * Created by agnither on 23.04.14.
 */
package com.orchideus.monsters.managers.leaderboard {
public class Leaderboard {

    public static function getLeaderboard():Leaderboard {
        BUILD::mobile {
            return new GameCenterLeaderboard();
        }
        return new Leaderboard();
    }

    public function Leaderboard() {
    }

    public function reportScore(leaderboard: String, score: int):void {
    }

    public function showLeaderboard(leaderboard: String):void {
    }
}
}
