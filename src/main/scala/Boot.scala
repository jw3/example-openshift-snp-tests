import scala.sys.process.Process

object Boot extends App {
  while (true) {
    val me = Process("whoami") !!

    println(s"hello, OpenShift from $me")
    Thread.sleep(5000)
  }
}
