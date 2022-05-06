using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PauseMenu : MonoBehaviour
{
    private bool m_paused;

    [SerializeField]
    private GameObject m_pauseMenu;

    [SerializeField]
    private PlayerInput playerInput;

    [SerializeField]
    private InputAction m_pauseGame;

    // Start is called before the first frame update
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
            m_pauseMenu.SetActive(false);
            Time.timeScale = 1.0f;
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Confined;
            m_paused = false;
        }
        else
        {
            m_pauseMenu.SetActive(true);
            Time.timeScale = 0.0f;
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.Locked;
            m_paused = true;
        }
    }
}
