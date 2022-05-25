using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManagerScript : MonoBehaviour
{

    public static GameManagerScript m_instance;

    List<IRestartGameElement> m_RestartGameElements;

    private void Awake()
    {

        if(m_instance != null)
        {
            Destroy(gameObject);
        } else
        {
            m_instance = this;
            m_RestartGameElements = new List<IRestartGameElement>();
            DontDestroyOnLoad(gameObject);
        }
    }
    public void AddRestartGameElement(IRestartGameElement RestartGameElement)
    {
        m_RestartGameElements.Add(RestartGameElement);
    }
    public void DeleteRestartGameElement(IRestartGameElement RestartGameElement)
    {
        m_RestartGameElements.Remove(RestartGameElement);
    }

    public void RestartGame()
    {
        foreach (IRestartGameElement l_RestartGameElement in m_RestartGameElements)
            l_RestartGameElement.RestartGame();
    }
}

public class Settings : MonoBehaviour
{



}
