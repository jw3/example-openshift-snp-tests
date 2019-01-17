import scala.sys.process.Process

object Boot extends App {
  while (true) {
    val me = try {
      Process("whoami") !!
    } catch {
      case x: RuntimeException ⇒ x.getMessage
      case e ⇒ e.getMessage
    }

    println(s"hello, OpenShift from $me")
    Thread.sleep(3000)
  }
}
