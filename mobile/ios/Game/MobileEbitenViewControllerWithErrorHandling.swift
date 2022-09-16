import Foundation
import Mobile

class MobileEbitenViewControllerWithErrorHandling: MobileEbitenViewController {
    override func onError(onGameUpdate err: Error?) {
        print("Game error: \(String(describing: err))")
    }
}
