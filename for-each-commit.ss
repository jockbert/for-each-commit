
import scala.annotation.tailrec
import java.io.File

val hasCmd = args.length == 1
val hasCmdAndStopCommit = args.length == 2
val hasValidArgs = hasCmd || hasCmdAndStopCommit

if (!hasValidArgs) println("Usage <command> [<stop commit>]")
else run(args)

def run(args : Array[String]) {
  val git = GitImpl_1_7()

  val stopCommit = if (hasCmdAndStopCommit) {

    println("Using " + args(1) + " as commit to stop on.")
    args(1)
  } else {

    println("Using repo root commit as commit to stop on.")
    git.rootCommit()
  }

  val climber = Climber(git)
  val command = args(0)

  println("Command to execute '" + command + "'.")

  climber.endUpOnStartCommit {
    climber.climb(stopCommit) { () =>
      Executor.executeSafe(command)
    }
  }
}

case class Climber(git: Git) {

  @tailrec
  final def climb(stopCommit: String)(fn: () => Boolean): Unit = {
    val commitHash = git.currentCommit()
    println()
    println("Is on commit " + commitHash)
    if (!fn()) println("Error when executing command - stopping climb.")
    else if (commitHash.startsWith(stopCommit)) println("Reached stop " + stopCommit + ".")
    else if (!git.backOneCommit()) println("Error when changing commit - stopping climb.")
    else climb(stopCommit)(fn)
  }

  def endUpOnStartCommit(fn: => Unit) {
    val startHash = git.currentCommit()
    println("Storing start commit " + startHash)

    fn

    println("Going back to start commit " + startHash + ".")
    git.goToCommit(startHash)
  }
}

trait Git {
  def currentCommit(): String
  def backOneCommit(): Boolean
  def rootCommit(): String
  def goToCommit(hash: String): Boolean
}

case class GitImpl_1_7() extends Git {
  import Executor._
  import language.postfixOps

  def currentCommit(): String = (execute("git rev-parse HEAD") !!).trim()
  def backOneCommit(): Boolean = goToCommit("HEAD~1")
  def rootCommit(): String = (execute("git rev-list --max-parents=0 HEAD") !!).trim()

  def goToCommit(commit: String): Boolean =
    executeSilent("git checkout " + commit).exitValue() == 0

}

case object Executor {
  import sys.process._

  private val logger = ProcessLogger(out => (), err => ())

  def executeSilent(cmd: String) = Process(cmd).run(logger)
  def execute(cmd: String) = Process(cmd)

  def executeSafe(cmd: String): Boolean =
    try {
      Process(cmd).run().exitValue() == 0
    } catch {
      case e: Throwable => println("Executor error: " + e.getMessage); false
    }
}
