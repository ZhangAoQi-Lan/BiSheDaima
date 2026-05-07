/**
 * 获取或创建本地匿名会话 ID（存在 localStorage，用于标识未登录用户的暂存箱）
 */
export function getOrCreateSessionId() {
  let sessionId = localStorage.getItem('__quote_session_id')
  if (!sessionId) {
    // 生成简单的伪 UUID
    sessionId = 'sess-' + Math.random().toString(36).slice(2) + Date.now().toString(36)
    localStorage.setItem('__quote_session_id', sessionId)
  }
  return sessionId
}
