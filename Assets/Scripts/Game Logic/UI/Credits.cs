using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class Credits : MonoBehaviour
{

    [SerializeField]
    private GameManagerScript m_gameManager;

    private GameObject m_player;

    [SerializeField]
    private Animation m_animation;

    [SerializeField]
    private GameObject m_background;

    [SerializeField]
    private GameObject m_frame;

    private string m_titleAnim;
    private string m_developersAnim;
    private string m_thanksAnim;
    private string m_changeToMainMenuAnim;

    private bool m_alreadyQuit;

    private void Awake()
    {
        m_titleAnim = "TheEndText";
        m_developersAnim = "ShowDeveloper";
        m_thanksAnim = "ThanksForPlaying";
        m_changeToMainMenuAnim = "ChangeToMainMenu";

        m_background = gameObject.transform.Find("Background").gameObject;
        m_frame = gameObject.transform.Find("Frame").gameObject;

        m_background.SetActive(false);
        m_frame.SetActive(false);

    }

    private void Update()
    {
        if (m_gameManager == null)
        {
            m_gameManager = GameObject.Find("GameManager").GetComponent<GameManagerScript>();
        }

        if (m_animation.IsPlaying(m_changeToMainMenuAnim) && !m_alreadyQuit)
        {
            m_gameManager.RestartRestartGameElement();
            m_gameManager.LoadMainMenuFromGame();
            Cursor.lockState = CursorLockMode.Confined;
            m_alreadyQuit = true;
        }
    }

    public void StartCinematics(GameObject l_player)
    {
        m_background.gameObject.SetActive(true);
        m_frame.gameObject.SetActive(true);

        m_player = l_player;

        m_player.GetComponent<CharacterController>().enabled = false;
        m_player.GetComponent<CharacterControllerScript>().enabled = false;
        m_player.GetComponent<WeaponController>().enabled = false;
        m_player.GetComponentInChildren<Animator>().enabled = false;
        m_player.GetComponent<PlayerInput>().enabled = false;

        m_animation.PlayQueued(m_titleAnim, QueueMode.CompleteOthers);
        m_animation.PlayQueued(m_developersAnim, QueueMode.CompleteOthers);
        m_animation.PlayQueued(m_thanksAnim, QueueMode.CompleteOthers);
        m_animation.PlayQueued(m_changeToMainMenuAnim, QueueMode.CompleteOthers);
    }

}
