using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManagerScript : MonoBehaviour
{
    List<IRestartGameElement> m_RestartGameElements;
    private bool m_paused;

    private void Awake()
    {
        m_RestartGameElements = new List<IRestartGameElement>();
        DontDestroyOnLoad(gameObject);
        m_paused = false;
    }
    public void AddRestartGameElement(IRestartGameElement RestartGameElement)
    {
        m_RestartGameElements.Add(RestartGameElement);
    }
    public void RestartGame()
    {
        foreach (IRestartGameElement l_RestartGameElement in m_RestartGameElements)
            l_RestartGameElement.RestartGame();
    }

    public void PauseGame()
    {
        if (m_paused == true)
        {
            Time.timeScale = 1.0f;
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Confined;
            m_paused = false;
        }
        else
        {
            Time.timeScale = 0.0f;
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.Locked;
            m_paused = true;
        }
    }
}
