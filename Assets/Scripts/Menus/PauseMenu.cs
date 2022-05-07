using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PauseMenu : MonoBehaviour
{
    private bool m_paused;

    [SerializeField]
    private GameObject m_blur;

    [SerializeField]
    private GameObject m_pauseMenu;

    [SerializeField]
    private PlayerInput playerInput;

    [SerializeField]
    private InputAction m_pauseGame;

    public bool GetPaused()
    {
        return m_paused;
    }

    void Start()
    {
        m_pauseGame = playerInput.actions["Pause"];
    }

    // Update is called once per frame
    void Update()
    {
        if (m_pauseGame.triggered)
        {
            PauseGame();
        }
    }
    public void PauseGame()
    {
        if (m_paused == true)
        {
            m_blur.SetActive(false);
            m_pauseMenu.SetActive(false);
            Time.timeScale = 1.0f;
            Cursor.visible = false;
            m_paused = false;
        }
        else
        {
            m_blur.SetActive(true);
            m_pauseMenu.SetActive(true);
            Time.timeScale = 0.0f;
            Cursor.visible = true;
            m_paused = true;
        }
    }
    public void Quit()
    {
        Application.Quit();
    }
}
